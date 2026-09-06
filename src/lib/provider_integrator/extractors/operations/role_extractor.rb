# frozen_string_literal: true

module ProviderIntegrator
  module Extractors
    module Operations
      # Определяет сервисную роль исходящей операции по OpenAPI metadata и response schema.
      class RoleExtractor < Base
        ROLE_EXTENSION = "x-provider-integrator-role"
        ROLE_PATTERNS = {
          cancel: /cancel/i,
          fetch_balance: /balance/i,
          fetch_status: /status/i
        }.freeze

        def initialize(document, path:, path_item:, http_method:, operation:)
          super(document)
          @path = path
          @path_item = path_item
          @http_method = http_method
          @operation = operation
        end

        def call
          explicit_role || metadata_role || response_role
        end

        private

        attr_reader :path, :path_item, :http_method, :operation

        def explicit_role
          value = extension(operation, ROLE_EXTENSION)
          return unless value.is_a?(String) && !value.empty?

          value.tr("-", "_").to_sym
        end

        def metadata_role
          text = [operation.operation_id, path].compact.join(" ")
          ROLE_PATTERNS.find { |_role, pattern| text.match?(pattern) }&.first
        end

        def response_role
          return unless http_method == :get

          properties = success_schemas(operation).flat_map { |schema| schema.properties&.keys.to_a }.uniq
          return :fetch_balance if properties.include?("balance")
          return :fetch_status if properties.include?("status") && path_parameters?

          nil
        end

        def path_parameters?
          effective_parameters(path_item, operation).any? do |parameter|
            parameter.public_send(:in) == "path"
          end
        end
      end
    end
  end
end
