# frozen_string_literal: true

module ProviderIntegrator
  module Extractors
    module Operations
      # Извлекает параметры дополнительной исходящей операции.
      class ParameterExtractor < Base
        OPERATION_ID_PATTERN = /(?:payout|operation|transaction)?_?id\z/i

        def initialize(document, path_item:, operation:)
          super(document)
          @path_item = path_item
          @operation = operation
        end

        def call
          effective_parameters(path_item, operation).map do |parameter|
            Model::RequestParameter.new(
              name: parameter.name,
              location: parameter.public_send(:in).to_sym,
              source_path: source_path(parameter),
              transform: :to_string,
              required: parameter.required?
            )
          end
        end

        private

        attr_reader :path_item, :operation

        def source_path(parameter)
          return unless parameter.public_send(:in) == "path"
          return unless parameter.name.match?(OPERATION_ID_PATTERN)

          "operation.provider_operation_id"
        end
      end
    end
  end
end
