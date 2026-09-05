# frozen_string_literal: true

module ProviderIntegrator
  module Extractors
    # Извлекает ограничения request fields как предварительные условия операции.
    class ConditionExtractor < Base
      MINOR_UNIT_FACTOR = 100
      MINOR_UNIT_PATTERN = /коп(?:ейк|еек)\p{L}*|коп\.|kopecks?|kopeks?|cents?|minor\s+units?/iu

      def initialize(document, operations:)
        super(document)
        @operations = operations
      end

      def call
        operation = create_request_operation
        schema = request_schema(operation)
        return [] unless operation && schema

        operation.request_fields.filter_map do |mapping|
          build_minimum_condition(schema, mapping)
        end
      end

      private

      attr_reader :operations

      def create_request_operation
        operations.find { |operation| operation.role == :create_request }
      end

      def request_schema(operation)
        return unless operation

        openapi_operation = document.paths[operation.path]&.public_send(operation.http_method)
        openapi_operation&.request_body&.content&.[]("application/json")&.schema
      end

      def build_minimum_condition(schema, mapping)
        property = find_property(schema, mapping.target_path)
        return unless property&.minimum
        return unless mapping.source_path

        value = normalize_value(property, mapping.transform)
        return if value.nil?

        Model::Condition.new(
          field: mapping.source_path,
          operator: :greater_than_or_equal,
          value: value,
          unit: operation_currency,
          failure_code: "#{mapping.target_path.tr('.', '_')}_too_low",
          source_pointer: source_pointer(property, "minimum")
        )
      end

      def find_property(schema, target_path)
        target_path.split(".").reduce(schema) do |current_schema, segment|
          current_schema&.properties&.[](segment)
        end
      end

      def normalize_value(property, transform)
        return property.minimum unless transform == :major_to_minor
        return unless property.description&.match?(MINOR_UNIT_PATTERN)

        quotient, remainder = property.minimum.divmod(MINOR_UNIT_FACTOR)
        remainder.zero? ? quotient : property.minimum.fdiv(MINOR_UNIT_FACTOR)
      end

      def operation_currency
        mapping = create_request_operation.request_fields.find do |field|
          field.target_path == "currency" && field.transform == :constant
        end

        mapping&.value&.downcase&.to_sym
      end

      def source_pointer(property, keyword)
        location = property.node_context.source_location.to_s.delete_prefix("#")
        "#{location}/#{keyword}"
      end
    end
  end
end
