# frozen_string_literal: true

module ProviderIntegrator
  module Extractors
    module Operations
      # Определяет сервисную роль исходящей операции по OpenAPI metadata и response schema.
      class RoleExtractor < Base
        ROLE_PATTERNS = {
          cancel: /cancel/i,
          fetch_balance: /balance/i,
          fetch_status: /status/i
        }.freeze

        def initialize(document, path:, http_method:, operation:)
          super(document)
          @path = path
          @http_method = http_method
          @operation = operation
        end

        def call
          metadata_role || response_role
        end

        private

        attr_reader :path, :http_method, :operation

        def metadata_role
          text = [operation.operation_id, path].compact.join(" ")
          ROLE_PATTERNS.find { |_role, pattern| text.match?(pattern) }&.first
        end

        def response_role
          return unless http_method == :get

          properties = success_schema&.properties&.keys.to_a
          return :fetch_balance if properties.include?("balance")
          return :fetch_status if properties.include?("status") && path_parameters?

          nil
        end

        def success_schema
          response = operation.responses.find { |status, _candidate| status.start_with?("2") }&.last
          response&.content&.values&.filter_map(&:schema)&.first
        end

        def path_parameters?
          operation.parameters.to_a.any? { |parameter| parameter.public_send(:in) == "path" }
        end
      end
    end
  end
end
