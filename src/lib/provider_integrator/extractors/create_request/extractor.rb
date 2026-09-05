# frozen_string_literal: true

module ProviderIntegrator
  module Extractors
    module CreateRequest
      # Координирует create request extractors и собирает Operation Model.
      class Extractor < Base
        def call
          endpoint = OperationExtractor.new(document).call
          return unless endpoint

          Model::Operation.new(
            role: :create_request,
            http_method: :post,
            path: endpoint.path,
            operation_id: endpoint.operation.operation_id,
            parameters: parameters(endpoint),
            request_fields: FieldMappingExtractor.new(document, operation: endpoint.operation).call,
            responses: ResponseExtractor.new(document, operation: endpoint.operation).call,
            source_pointer: "/paths/#{escape_pointer(endpoint.path)}/post"
          )
        end

        private

        def parameters(endpoint)
          ParameterExtractor.new(
            document,
            path_item: endpoint.path_item,
            operation: endpoint.operation
          ).call
        end
      end
    end
  end
end
