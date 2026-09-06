# frozen_string_literal: true

module ProviderIntegrator
  module Extractors
    module CreateRequest
      # Извлекает однозначные mappings полей create request.
      class FieldMappingExtractor < Base
        RECIPIENT_FIELDS = %w[phone bank_code bank_name card_number].freeze

        def initialize(document, operation:)
          super(document)
          @operation = operation
        end

        def call
          schema = json_schema
          return [] unless schema

          required_fields = schema.required&.to_a || []
          explicit_mappings = extension_hash(operation, "x-provider-integrator-request-mappings")
          schema.properties.flat_map do |name, property|
            if explicit_mappings.key?(name)
              [explicit_mapping(name, explicit_mappings.fetch(name), required_fields.include?(name))]
            else
              build_mappings(name, property, required_fields.include?(name))
            end
          end
        end

        private

        attr_reader :operation

        def json_schema
          operation.request_body.content["application/json"]&.schema
        end

        def explicit_mapping(name, target_path, required)
          field_mapping(name, target_path.to_s, :identity, required: required)
        end

        def build_mappings(name, property, required)
          case name
          when "amount"
            [field_mapping(name, "operation.amount", :major_to_minor, required: required)]
          when "external_id"
            [field_mapping(name, "operation.id", :to_string, required: required)]
          when "currency"
            [constant_mapping(name, property, required: required)].compact
          when "recipient"
            recipient_mappings(property, required: required)
          else
            []
          end
        end

        def recipient_mappings(schema, required:)
          example = recipient_example
          variant = example&.[]("type") || single_enum_value(schema.properties&.[]("type"))
          fields = recipient_fields(schema, example)

          [recipient_type_mapping(schema, example, required: required), *fields.filter_map do |name|
            recipient_field_mapping(name, variant, schema, required: required)
          end].compact
        end

        def recipient_type_mapping(schema, example, required:)
          property = schema.properties&.[]("type")
          return unless property

          value = example&.[]("type") || single_enum_value(property)
          return constant_value_mapping("recipient.type", value, required: required) if value

          field_mapping("recipient.type", "operation.payout_requisite.type", :identity, required: required)
        end

        def recipient_field_mapping(name, variant, schema, required:)
          source_path = ["operation.payout_requisite", variant, name].compact.join(".")
          nested_required = schema.required&.to_a&.include?(name)

          field_mapping("recipient.#{name}", source_path, :identity, required: required && nested_required)
        end

        def recipient_fields(schema, example)
          available = schema.properties&.keys.to_a & RECIPIENT_FIELDS
          return available unless example.is_a?(Hash)

          available & example.keys
        end

        def recipient_example
          media_type = operation.request_body.content["application/json"]
          request_example = media_type.example || media_type.examples&.values&.first&.value
          request_example&.[]("recipient") if request_example.is_a?(Hash)
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
          value = single_enum_value(property)
          return unless value

          constant_value_mapping(target_path, value, required: required)
        end

        def constant_value_mapping(target_path, value, required:)
          Model::FieldMapping.new(
            target_path: target_path,
            transform: :constant,
            required: required,
            value: value
          )
        end

        def single_enum_value(property)
          values = property&.enum&.to_a || []
          values.first if values.one?
        end
      end
    end
  end
end
