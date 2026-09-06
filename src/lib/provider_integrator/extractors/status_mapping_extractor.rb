# frozen_string_literal: true

module ProviderIntegrator
  module Extractors
    # Строит поддерживаемый status map по enum успешного status response.
    class StatusMappingExtractor < Base
      INTERNAL_STATUSES = {
        "pending" => "in_progress",
        "processing" => "in_progress",
        "completed" => "approved",
        "failed" => "rejected",
        "cancelled" => "rejected"
      }.freeze

      def initialize(document, operations:)
        super(document)
        @operations = operations
      end

      def call
        explicit_mappings = explicit_status_mappings
        return explicit_mappings if explicit_mappings.any?

        provider_statuses.filter_map do |provider_status|
          internal_status = INTERNAL_STATUSES[provider_status]
          next unless internal_status

          Model::StatusMapping.new(
            provider_status: provider_status,
            internal_status: internal_status
          )
        end
      end

      private

      attr_reader :operations

      def provider_statuses
        operation = operations.find { |candidate| candidate.role == :fetch_status }
        return [] unless operation

        openapi_operation = document.paths[operation.path]&.public_send(operation.http_method)
        explicit_mappings = extension_hash(openapi_operation, "x-provider-integrator-status-mappings")
        return explicit_mappings.keys.map(&:to_s) if explicit_mappings.any?

        success_schemas(openapi_operation).flat_map do |schema|
          schema.properties&.[]("status")&.enum&.to_a || []
        end.uniq
      end

      def explicit_status_mappings
        operation = operations.find { |candidate| candidate.role == :fetch_status }
        return [] unless operation

        openapi_operation = document.paths[operation.path]&.public_send(operation.http_method)
        extension_hash(openapi_operation,
                       "x-provider-integrator-status-mappings").filter_map do |provider_status, internal_status|
          next unless internal_status

          Model::StatusMapping.new(
            provider_status: provider_status.to_s,
            internal_status: internal_status.to_s
          )
        end
      end
    end
  end
end
