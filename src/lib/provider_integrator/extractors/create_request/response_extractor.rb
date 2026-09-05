# frozen_string_literal: true

module ProviderIntegrator
  module Extractors
    module CreateRequest
      # Классифицирует ответы create request по HTTP-статусу.
      class ResponseExtractor < Base
        def initialize(document, operation:)
          super(document)
          @operation = operation
        end

        def call
          operation.responses.map do |status, response|
            kind = response_kind(status)
            Model::ResponseCase.new(
              http_status: status,
              kind: kind,
              field_mappings: kind == :success ? success_mappings(response) : []
            )
          end
        end

        private

        attr_reader :operation

        def success_mappings(response)
          schema = response.content&.[]("application/json")&.schema
          return [] unless schema

          mappings = []
          provider_id = %w[id payout_id transaction_id].find { |name| schema.properties&.keys&.include?(name) }
          mappings << response_mapping(provider_id, "operation.provider_operation_id") if provider_id
          mappings << response_mapping("status", "operation.status") if schema.properties&.keys&.include?("status")
          mappings
        end

        def response_mapping(source, target)
          Model::FieldMapping.new(
            target_path: target,
            source_path: "response.#{source}",
            transform: :identity,
            required: false
          )
        end

        def response_kind(status)
          return :success if status.start_with?("2")
          return :duplicate if status == "409"

          :error
        end
      end
    end
  end
end
