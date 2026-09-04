# frozen_string_literal: true

module ProviderIntegrator
  module Extractors
    # Извлекает идентификационные данные провайдера и основной API URL.
    class ProviderExtractor < Base
      TITLE_SUFFIX = /\s+(?:(?:payout|payment|payments|integration)\s+)?api\b.*\z/i

      def call
        Model::Provider.new(
          name: provider_name,
          slug: technical_name,
          class_name: class_name,
          base_url: document.servers.first&.url,
          base_url_env_name: "#{technical_name.upcase}_BASE_URL"
        )
      end

      private

      def provider_name
        document.info.title.sub(TITLE_SUFFIX, "").strip
      end

      def class_name
        technical_name.split("_").map(&:capitalize).join
      end

      def technical_name
        @technical_name ||= begin
          value = provider_name.downcase.gsub(/[^a-z0-9]+/, "_").gsub(/\A_|_\z/, "")
          raise ArgumentError, "Provider name must contain Latin letters or digits" if value.empty?

          value
        end
      end
    end
  end
end
