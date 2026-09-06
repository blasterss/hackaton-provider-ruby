# frozen_string_literal: true

module ProviderIntegrator
  module Extractors
    module CreateRequest
      # Находит операцию создания сущности с request body.
      class OperationExtractor < Base
        Endpoint = Data.define(:path, :path_item, :operation)
        ROLE_EXTENSION = "x-provider-integrator-role"

        def call
          endpoints = document.paths.filter_map do |path, path_item|
            operation = path_item.post
            next unless operation&.request_body

            Endpoint.new(path: path, path_item: path_item, operation: operation)
          end

          explicit = endpoints.find { |endpoint| explicit_create?(endpoint.operation) }
          explicit || endpoints.find { |endpoint| inferred_create?(endpoint.operation) }
        end

        private

        def explicit_create?(operation)
          explicit_role = operation.node_context.input[ROLE_EXTENSION]
          explicit_role.to_s.tr("-", "_") == "create_request"
        end

        def inferred_create?(operation)
          operation.node_context.input[ROLE_EXTENSION].nil? && operation.operation_id.to_s.match?(/create/i)
        end
      end
    end
  end
end
