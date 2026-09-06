# frozen_string_literal: true

module ProviderIntegrator
  module Parsers
    # Преобразует документы OpenAPI провайдера в формат, пригодный
    # для обработки парсером openapi3_parser версии 0.10.1.
    #
    # Процесс нормализации намеренно сделан явным: каждое преобразование
    # должно соответствовать конкретной известной несовместимости парсера.
    class OpenapiNormalizer
      Result = Data.define(:document, :changes)

      def initialize(document)
        @document = deep_dup(document)
        @changes = []
      end

      def call
        normalize_version
        normalize_root
        normalize_components

        Result.new(
          document: document,
          changes: changes.freeze
        )
      end

      private

      attr_reader :document, :changes

      # openapi3_parser 0.10.1 реализует спецификацию OpenAPI 3.0.
      def normalize_version
        version = document["openapi"]

        return unless version&.start_with?("3.1")

        document["openapi"] = "3.0.3"

        changes << {
          path: "#/openapi",
          action: :replace,
          from: version,
          to: "3.0.3",
          reason: "openapi3_parser 0.10.1 supports OpenAPI 3.0"
        }
      end

      def normalize_root
        move_webhooks_to_paths
      end

      def normalize_components
        schemas = document.dig("components", "schemas")
        normalize_schema_collection(schemas)
      end

      def normalize_schema_collection(schemas)
        return unless schemas.is_a?(Hash)

        schemas.each do |name, schema|
          normalize_schema(schema, "#/components/schemas/#{escape(name)}")
        end
      end

      def normalize_schema(schema, path)
        return unless schema.is_a?(Hash)

        normalize_schema_examples(schema, path)

        schema.each do |key, value|
          child_path = "#{path}/#{escape(key)}"

          case value
          when Hash
            normalize_schema(value, child_path)
          when Array
            value.each_with_index do |item, index|
              normalize_schema(item, "#{child_path}/#{index}")
            end
          end
        end
      end

      # Объект Schema в OpenAPI 3.1 основан на JSON Schema 2020-12.
      #
      # Парсер openapi3_parser версии 0.10.1 отвергает поле `examples` в объектах Schema.
      #
      # Важно:
      #   Это действие удаляет поле `examples` только из объектов Schema.
      def normalize_schema_examples(schema, path)
        return unless schema.key?("examples")

        examples = schema.delete("examples")

        changes << {
          path: "#{path}/examples",
          action: :remove,
          value: examples,
          reason: "Schema Object `examples` is not supported by openapi3_parser 0.10.1"
        }
      end

      def move_webhooks_to_paths
        webhooks = document.delete("webhooks")
        return unless webhooks.is_a?(Hash)

        document["paths"] ||= {}

        webhooks.each do |name, path_item|
          path = webhook_path(name)

          if document["paths"].key?(path)
            raise ArgumentError, "Webhook path collision: #{path}"
          end

          document["paths"][path] = path_item
        end

        changes << {
          path: "#/webhooks",
          action: :move,
          to: "#/paths",
          reason: "OpenAPI 3.1 webhooks are represented as paths for openapi3_parser 0.10.1"
        }
      end

      def webhook_path(name)
        "/webhooks/#{name}"
      end

      def remove_root_field(name)
        return unless document.key?(name)

        value = document.delete(name)

        changes << {
          path: "#/#{escape(name)}",
          action: :remove,
          value: value,
          reason: "Root field is not supported by openapi3_parser 0.10.1"
        }
      end

      def escape(value)
        value.to_s
             .gsub("~", "~0")
             .gsub("/", "~1")
      end

      def deep_dup(value)
        case value
        when Hash
          value.each_with_object({}) do |(key, item), copy|
            copy[key] = deep_dup(item)
          end
        when Array
          value.map { |item| deep_dup(item) }
        else
          value
        end
      end
    end
  end
end
