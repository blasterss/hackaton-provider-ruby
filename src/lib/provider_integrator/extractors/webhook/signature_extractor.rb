# frozen_string_literal: true

module ProviderIntegrator
  module Extractors
    module Webhook
      # Извлекает правило проверки подписи webhook из header-параметра.
      class SignatureExtractor < Base
        SECRET_KEY = :callback_secret
        ENCODING = :hex
        ALGORITHMS = {
          /hmac[-_\s]?sha[-_\s]?256/i => :hmac_sha256
        }.freeze

        def initialize(document, operation:)
          super(document)
          @operation = operation
        end

        def call
          header = signature_header
          algorithm = signature_algorithm(header)
          return unless header && algorithm

          Model::Signature.new(
            algorithm: algorithm,
            header: header.name,
            secret_key: SECRET_KEY,
            encoding: ENCODING
          )
        end

        private

        attr_reader :operation

        def signature_header
          operation.parameters.to_a.find do |parameter|
            parameter.public_send(:in) == "header" &&
              [parameter.name, parameter.description].compact.any? { |value| value.match?(/signature|подпис/i) }
          end
        end

        def signature_algorithm(header)
          text = [operation.description, header&.description].compact.join(" ")
          ALGORITHMS.find { |pattern, _algorithm| text.match?(pattern) }&.last
        end
      end
    end
  end
end
