# frozen_string_literal: true

module ProviderIntegrator
  module Extractors
    module CreateRequest
      # Классифицирует ответы create request по HTTP-статусу.
      class ResponseExtractor < Base
        def initialize(document, operation:)
          super(document)
          @operation = operation
        end

        def call
          operation.responses.map do |status, _response|
            Model::ResponseCase.new(
              http_status: status,
              kind: response_kind(status)
            )
          end
        end

        private

        attr_reader :operation

        def response_kind(status)
          return :success if status.start_with?("2")
          return :duplicate if status == "409"

          :error
        end
      end
    end
  end
end
