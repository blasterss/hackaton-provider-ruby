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
          base_url: production_server&.url,
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

      def production_server
        servers = document.servers.to_a
        described_server = servers.find do |server|
          server.description.to_s.match?(/\bproduction\b|\blive\b/i)
        end
        return described_server if described_server

        non_sandbox_server = servers.find do |server|
          server.url !~ /sandbox|staging|test/i
        end
        non_sandbox_server || servers.first
      end
    end
  end
end
