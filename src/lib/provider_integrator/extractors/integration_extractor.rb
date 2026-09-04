# frozen_string_literal: true

module ProviderIntegrator
  module Extractors
    # Собирает нормализованную Integration Model из результатов extractors.
    class IntegrationExtractor < Base
      attr_reader :slug

      def initialize(document, slug:)
        super(document)
        @slug = slug
      end

      def call
        Model::Integration.new(
          provider: ProviderExtractor.new(document, slug: slug).call,
          authentication: AuthenticationExtractor.new(document).call
        )
      end
    end
  end
end
