# frozen_string_literal: true

module ProviderIntegrator
  module Extractors
    # Извлекает идентификационные данные провайдера и основной API URL.
    class ProviderExtractor < Base
      TITLE_SUFFIX = /\s+(?:(?:payout|payment|payments|integration)\s+)?api\b.*\z/i

      attr_reader :slug

      def initialize(document, slug:)
        super(document)
        @slug = slug
      end

      def call
        Model::Provider.new(
          name: provider_name,
          slug: slug,
          class_name: class_name,
          base_url: document.servers.first&.url,
          base_url_env_name: "#{normalized_slug.upcase}_BASE_URL"
        )
      end

      private

      def provider_name
        document.info.title.sub(TITLE_SUFFIX, "").strip
      end

      def class_name
        normalized_slug.split("_").map(&:capitalize).join
      end

      def normalized_slug
        @normalized_slug ||= slug.downcase.gsub(/[^a-z0-9]+/, "_").gsub(/\A_|_\z/, "")
      end
    end
  end
end
