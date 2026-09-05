# frozen_string_literal: true

module ProviderIntegrator
  module Generators
    # Подготавливает Integration Model к отрисовке Ruby service templates.
    class ServiceView
      class UnsupportedMappingError < StandardError
      end

      def initialize(integration)
        @integration = integration
      end

      def operation(role)
        integration.operations.find { |operation| operation.role == role }
      end

      def payload_source(mappings, indent: 6)
        render_hash(mapping_tree(mappings), indent)
      end

      def value_expression(mapping)
        return ruby_literal(mapping.value) if mapping.transform == :constant

        source = source_expression(mapping.source_path)
        case mapping.transform
        when :identity
          source
        when :to_string
          "#{source}.to_s"
        when :major_to_minor
          "(#{source} * 100).to_i"
        else
          raise UnsupportedMappingError, "Unsupported mapping transform: #{mapping.transform}"
        end
      end

      def response_assignment(mapping)
        target = direct_attribute_expression(mapping.target_path)
        "#{target} = #{value_expression(mapping)}"
      end

      private

      attr_reader :integration

      def mapping_tree(mappings)
        mappings.each_with_object({}) do |mapping, root|
          segments = mapping.target_path.split(".")
          leaf = segments.pop
          branch = segments.reduce(root) { |current, segment| current[segment] ||= {} }
          branch[leaf] = mapping
        end
      end

      def render_hash(node, indent)
        entries = node.map do |key, value|
          rendered_value = value.is_a?(Hash) ? render_hash(value, indent + 2) : value_expression(value)
          "#{" " * (indent + 2)}#{ruby_hash_key(key)} #{rendered_value}"
        end

        body = entries.each_with_index.map do |entry, index|
          index == entries.length - 1 ? entry : "#{entry},"
        end
        (["{"] + body + ["#{" " * indent}}"]).join("\n")
      end

      def ruby_hash_key(key)
        key.match?(/\A[a-zA-Z_]\w*\z/) ? "#{key}:" : "#{key.dump} =>"
      end

      def ruby_literal(value)
        value.inspect
      end

      def source_expression(path)
        raise UnsupportedMappingError, "Mapping source path is missing" unless path

        root, attribute, *nested = path.split(".")
        case root
        when "operation"
          expression = "operation.#{attribute}"
          nested.empty? ? expression : "#{expression}.dig(#{nested.map(&:dump).join(", ")})"
        when "response"
          response_body_expression([attribute, *nested])
        else
          raise UnsupportedMappingError, "Unsupported mapping source: #{path}"
        end
      end

      def response_body_expression(segments)
        return "response.body.fetch(#{segments.first.dump})" if segments.one?

        "response.body.dig(#{segments.map(&:dump).join(", ")})"
      end

      def direct_attribute_expression(path)
        root, attribute, *nested = path.split(".")
        if root != "operation" || attribute.nil? || nested.any?
          raise UnsupportedMappingError, "Unsupported mapping target: #{path}"
        end

        "operation.#{attribute}"
      end
    end
  end
end
