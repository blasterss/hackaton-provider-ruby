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

          mappings = explicit_mappings
          provider_id = %w[id payout_id transaction_id].find { |name| schema.properties&.keys&.include?(name) }
          unless mappings.any? { |mapping| mapping.target_path == "operation.provider_operation_id" }
            mappings << response_mapping(provider_id, "operation.provider_operation_id") if provider_id
          end
          mappings << response_mapping("status", "operation.status") if schema.properties&.keys&.include?("status")
          mappings.uniq
        end

        def explicit_mappings
          extension_hash(operation, "x-provider-integrator-response-mappings").filter_map do |source_path, target_path|
            next unless target_path

            response_mapping(source_path.to_s, target_path.to_s)
          end
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
