# frozen_string_literal: true

module ProviderIntegrator
  module Extractors
    # Собирает нормализованную Integration Model из результатов extractors.
    class IntegrationExtractor < Base
      def call
        Model::Integration.new(
          provider: ProviderExtractor.new(document).call,
          authentication: AuthenticationExtractor.new(document).call
        )
      end
    end
  end
end
