# frozen_string_literal: true

module ProviderIntegrator
  module Extractors
    module CreateRequest
      # Находит операцию создания сущности с request body.
      class OperationExtractor < Base
        Endpoint = Data.define(:path, :path_item, :operation)

        def call
          document.paths.each do |path, path_item|
            operation = path_item.post
            next unless operation&.request_body
            next unless operation.operation_id.to_s.match?(/create/i)

            return Endpoint.new(path: path, path_item: path_item, operation: operation)
          end

          nil
        end
      end
    end
  end
end
