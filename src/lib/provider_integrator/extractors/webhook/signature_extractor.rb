# frozen_string_literal: true

module ProviderIntegrator
  module Extractors
    module Webhook
      # Извлекает правило проверки подписи webhook из header-параметра.
      class SignatureExtractor < Base
        SECRET_KEY = :callback_secret
        ALGORITHMS = {
          /hmac[-_\s]?sha[-_\s]?256/i => :hmac_sha256
        }.freeze
        ENCODINGS = {
          /\bhex(?:adecimal)?\b|шестнадцатерич/iu => :hex,
          /\bbase[-_\s]?64\b/i => :base64
        }.freeze

        def initialize(document, path_item:, operation:)
          super(document)
          @path_item = path_item
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
            encoding: signature_encoding(header)
          )
        end

        private

        attr_reader :path_item, :operation

        def signature_header
          effective_parameters(path_item, operation).find do |parameter|
            parameter.public_send(:in) == "header" &&
              [parameter.name, parameter.description].compact.any? { |value| value.match?(/signature|подпис/i) }
          end
        end

        def signature_algorithm(header)
          ALGORITHMS.find { |pattern, _algorithm| signature_description(header).match?(pattern) }&.last
        end

        def signature_encoding(header)
          ENCODINGS.find { |pattern, _encoding| signature_description(header).match?(pattern) }&.last
        end

        def signature_description(header)
          [operation.description, header&.name, header&.description].compact.join(" ")
        end
      end
    end
  end
end
