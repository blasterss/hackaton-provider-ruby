# frozen_string_literal: true

module ProviderIntegrator
  module Extractors
    # Собирает нормализованную Integration Model из результатов extractors.
    class IntegrationExtractor < Base
      def call
        webhook = Webhook::Extractor.new(document).call
        create_request = CreateRequest::Extractor.new(document).call
        operations = [
          create_request,
          *Operations::Extractor.new(document).call
        ].compact.reject do |operation|
          webhook_operation?(operation, webhook) || duplicate_create_request?(operation, create_request)
        end
        status_mappings = StatusMappingExtractor.new(document, operations: operations).call
        fixtures = FixtureExtractor.new(document, operations: operations, webhook: webhook).call

        Model::Integration.new(
          provider: ProviderExtractor.new(document).call,
          authentication: AuthenticationExtractor.new(document, operations: operations).call,
          operations: operations,
          webhook: webhook,
          conditions: ConditionExtractor.new(document, operations: operations).call,
          error_mappings: ErrorMappingExtractor.new(document, operations: operations).call,
          status_mappings: status_mappings,
          fixtures: fixtures,
          diagnostics: DiagnosticExtractor.new(
            document,
            operations: operations,
            webhook: webhook,
            status_mappings: status_mappings,
            fixtures: fixtures
          ).call
        )
      end

      private

      def webhook_operation?(operation, webhook)
        webhook && operation.http_method == :post && operation.path == webhook.path
      end

      def duplicate_create_request?(operation, create_request)
        create_request && operation.role != :create_request &&
          operation.http_method == create_request.http_method && operation.path == create_request.path
      end
    end
  end
end
