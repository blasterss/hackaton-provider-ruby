# frozen_string_literal: true

module ProviderIntegrator
  module Extractors
    module Operations
      # Классифицирует ответы дополнительной исходящей операции.
      class ResponseExtractor < Base
        def initialize(document, operation:)
          super(document)
          @operation = operation
        end

        def call
          operation.responses.map do |status, _response|
            Model::ResponseCase.new(
              http_status: status,
              kind: status.start_with?("2") ? :success : :error
            )
          end
        end

        private

        attr_reader :operation
      end
    end
  end
end
