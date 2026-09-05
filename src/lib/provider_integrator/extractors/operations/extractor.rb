# frozen_string_literal: true

module ProviderIntegrator
  module Extractors
    module Operations
      # Собирает поддерживаемые дополнительные исходящие операции.
      class Extractor < Base
        def call
          EndpointExtractor.new(document).call.map { |endpoint| build_operation(endpoint) }
        end

        private

        def build_operation(endpoint)
          Model::Operation.new(
            role: endpoint.role,
            http_method: endpoint.http_method,
            path: endpoint.path,
            operation_id: endpoint.operation.operation_id,
            parameters: parameters(endpoint),
            responses: ResponseExtractor.new(document, operation: endpoint.operation).call,
            source_pointer: "/paths/#{escape_pointer(endpoint.path)}/#{endpoint.http_method}"
          )
        end

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
