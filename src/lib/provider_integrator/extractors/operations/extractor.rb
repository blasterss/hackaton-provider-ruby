# frozen_string_literal: true

module ProviderIntegrator
  module Extractors
    module Operations
      # Собирает поддерживаемые дополнительные исходящие операции.
      class Extractor < Base
        def call
          EndpointExtractor.new(document).call.filter_map do |endpoint|
            next if endpoint.role == :create_request

            build_operation(endpoint)
          end
        end

        private

        def build_operation(endpoint)
          Model::Operation.new(
            role: endpoint.role || :unsupported,
            http_method: endpoint.http_method,
            path: endpoint.path,
            operation_id: endpoint.operation.operation_id,
            parameters: parameters(endpoint),
            responses: ResponseExtractor.new(document, operation: endpoint.operation).call,
            status_source_path: extension(endpoint.operation, "x-provider-integrator-status-path"),
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
