# frozen_string_literal: true

module ProviderIntegrator
  module Extractors
    # Собирает нормализованную Integration Model из результатов extractors.
    class IntegrationExtractor < Base
      def call
        operations = [
          CreateRequestExtractor.new(document).call,
          *OperationsExtractor.new(document).call
        ].compact
        webhook = Webhook::Extractor.new(document).call

        Model::Integration.new(
          provider: ProviderExtractor.new(document).call,
          authentication: AuthenticationExtractor.new(document).call,
          operations: operations,
          webhook: webhook,
          conditions: ConditionExtractor.new(document, operations: operations).call,
          error_mappings: ErrorMappingExtractor.new(document, operations: operations).call,
          status_mappings: StatusMappingExtractor.new(document, operations: operations).call,
          fixtures: FixtureExtractor.new(document, operations: operations, webhook: webhook).call
        )
      end
    end
  end
end
