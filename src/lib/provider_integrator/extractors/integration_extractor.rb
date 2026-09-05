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

        Model::Integration.new(
          provider: ProviderExtractor.new(document).call,
          authentication: AuthenticationExtractor.new(document).call,
          operations: operations,
          conditions: ConditionExtractor.new(document, operations: operations).call,
          status_mappings: StatusMappingExtractor.new(document, operations: operations).call
        )
      end
    end
  end
end
