# frozen_string_literal: true

module ProviderIntegrator
  module Extractors
    # Извлекает операцию создания выплаты и однозначные request mappings.
    class CreateRequestExtractor < Base
      IDEMPOTENCY_HEADER = "idempotency-key"

      def call
        endpoint = create_request_endpoint
        build_operation(*endpoint) if endpoint
      end

      private

      def create_request_endpoint
        document.paths.each do |path, path_item|
          operation = path_item.post
          next unless operation&.request_body
          next unless operation.operation_id.to_s.match?(/create/i)

          return [path, path_item, operation]
        end

        nil
      end

      def build_operation(path, path_item, operation)
        Model::Operation.new(
          role: :create_request,
          http_method: :post,
          path: path,
          operation_id: operation.operation_id,
          parameters: request_parameters(path_item, operation),
          request_fields: request_fields(operation),
          responses: response_cases(operation),
          source_pointer: "/paths/#{escape_pointer(path)}/post"
        )
      end

      def request_parameters(path_item, operation)
        [*path_item.parameters, *operation.parameters].map do |parameter|
          idempotency = parameter.name.downcase == IDEMPOTENCY_HEADER

          Model::RequestParameter.new(
            name: parameter.name,
            location: parameter.public_send(:in).to_sym,
            source_path: idempotency ? "operation.id" : nil,
            transform: idempotency ? :to_string : :identity,
            required: parameter.required?
          )
        end
      end

      def request_fields(operation)
        schema = json_schema(operation)
        return [] unless schema

        required_fields = schema.required&.to_a || []
        schema.properties.filter_map do |name, property|
          build_field_mapping(name, property, required_fields.include?(name))
        end
      end

      def build_field_mapping(name, property, required)
        case name
        when "amount"
          field_mapping(name, "operation.amount", :major_to_minor, required: required)
        when "external_id"
          field_mapping(name, "operation.id", :to_string, required: required)
        when "currency"
          constant_mapping(name, property, required: required)
        end
      end

      def field_mapping(target_path, source_path, transform, required:)
        Model::FieldMapping.new(
          target_path: target_path,
          source_path: source_path,
          transform: transform,
          required: required
        )
      end

      def constant_mapping(target_path, property, required:)
        values = property.enum&.to_a || []
        return unless values.one?

        Model::FieldMapping.new(
          target_path: target_path,
          transform: :constant,
          required: required,
          value: values.first
        )
      end

      def json_schema(operation)
        operation.request_body.content["application/json"]&.schema
      end

      def response_cases(operation)
        operation.responses.map do |status, _response|
          Model::ResponseCase.new(
            http_status: status,
            kind: response_kind(status)
          )
        end
      end

      def response_kind(status)
        return :success if status.start_with?("2")
        return :duplicate if status == "409"

        :error
      end
    end
  end
end
