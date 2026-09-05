# frozen_string_literal: true

module ProviderIntegrator
  module Extractors
    module CreateRequest
      # Извлекает однозначные mappings полей create request.
      class FieldMappingExtractor < Base
        def initialize(document, operation:)
          super(document)
          @operation = operation
        end

        def call
          schema = json_schema
          return [] unless schema

          required_fields = schema.required&.to_a || []
          schema.properties.filter_map do |name, property|
            build_mapping(name, property, required_fields.include?(name))
          end
        end

        private

        attr_reader :operation

        def json_schema
          operation.request_body.content["application/json"]&.schema
        end

        def build_mapping(name, property, required)
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
      end
    end
  end
end
