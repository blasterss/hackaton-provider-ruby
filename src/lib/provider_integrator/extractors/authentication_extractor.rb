# frozen_string_literal: true

module ProviderIntegrator
  module Extractors
    # Извлекает схему авторизации, используемую исходящими операциями.
    class AuthenticationExtractor < Base
      class UnsupportedAuthenticationError < StandardError
      end

      SUPPORTED_SCHEME_TYPES = %w[apiKey http].freeze

      def initialize(document, operations:)
        super(document)
        @operations = operations
      end

      def call
        scheme_names = required_security_scheme_names
        return if scheme_names.empty?
        raise UnsupportedAuthenticationError,
              "Multiple security schemes are not supported yet" if scheme_names.size > 1

        build_authentication(security_schemes[scheme_names.first])
      end

      private

      attr_reader :operations

      def security_schemes
        document.components&.security_schemes || {}
      end

      def required_security_scheme_names
        operations
          .flat_map do |operation|
          openapi_operation =
            document.paths[operation.path]&.public_send(operation.http_method)
          security_requirements(openapi_operation)
        end
        .flat_map(&:keys)
        .uniq
        .select { |name| supported_security_scheme?(name) }
      end

      def supported_security_scheme?(name)
        scheme = security_schemes[name]
        scheme && SUPPORTED_SCHEME_TYPES.include?(scheme.type)
      end

      def security_requirements(operation)
        return [] unless operation

        requirements =
          if operation.node_context.input.key?("security")
            operation.security.to_a
          else
            document.security.to_a
          end
        requirements.any? { |requirement| requirement.keys.empty? } ? [] : requirements
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
