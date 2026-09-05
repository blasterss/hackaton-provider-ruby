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

        openapi_operation = document.paths[operation.path]&.get
        response = openapi_operation&.responses&.find do |status, _candidate|
          status.start_with?("2")
        end&.last
        schema = response&.content&.values&.filter_map(&:schema)&.find do |candidate|
          candidate.properties&.keys&.include?("status")
        end

        status_schema = schema&.properties&.[]("status")
        status_schema&.enum&.to_a || []
      end
    end
  end
end
