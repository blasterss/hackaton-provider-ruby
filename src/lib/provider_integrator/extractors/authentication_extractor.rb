# frozen_string_literal: true

module ProviderIntegrator
  module Extractors
    # Извлекает поддерживаемую схему авторизации из components.securitySchemes.
    class AuthenticationExtractor < Base
      class UnsupportedAuthenticationError < StandardError
      end

      def call
        return if security_schemes.empty?
        raise UnsupportedAuthenticationError,
              "Multiple security schemes are not supported yet" if security_schemes.size > 1

        build_authentication(security_schemes.values.first)
      end

      private

      def security_schemes
        document.components&.security_schemes || {}
      end

      def build_authentication(scheme)
        case scheme.type
        when "apiKey"
          api_key_authentication(scheme)
        when "http"
          http_authentication(scheme)
        else
          raise UnsupportedAuthenticationError, "Unsupported authentication type: #{scheme.type}"
        end
      end

      def api_key_authentication(scheme)
        Model::Authentication.new(
          type: :api_key,
          location: scheme.public_send(:in).to_sym,
          parameter_name: scheme.name,
          credential_key: :api_key
        )
      end

      def http_authentication(scheme)
        unless scheme.scheme&.casecmp?("bearer")
          raise UnsupportedAuthenticationError, "Unsupported HTTP authentication scheme: #{scheme.scheme}"
        end

        Model::Authentication.new(
          type: :bearer,
          location: :header,
          parameter_name: "Authorization",
          credential_key: :access_token
        )
      end
    end
  end
end
