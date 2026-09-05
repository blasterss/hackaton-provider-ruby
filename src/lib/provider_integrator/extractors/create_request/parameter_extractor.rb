# frozen_string_literal: true

module ProviderIntegrator
  module Extractors
    module CreateRequest
      # Извлекает header, path и query параметры create request.
      class ParameterExtractor < Base
        IDEMPOTENCY_HEADER = "idempotency-key"

        def initialize(document, path_item:, operation:)
          super(document)
          @path_item = path_item
          @operation = operation
        end

        def call
          effective_parameters(path_item, operation).map do |parameter|
            build_parameter(parameter)
          end
        end

        private

        attr_reader :path_item, :operation

        def build_parameter(parameter)
          idempotency = parameter.name.downcase == IDEMPOTENCY_HEADER

          Model::RequestParameter.new(
            name: parameter.name,
            location: parameter.public_send(:in).to_sym,
            source_path: idempotency ? "operation.id" : nil,
            transform: idempotency ? :to_string : :identity,
            required: parameter.required?
          )
        end
      end
    end
  end
end
