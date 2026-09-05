# frozen_string_literal: true

module ProviderIntegrator
  module Extractors
    module Webhook
      # Находит входящую webhook-операцию в OpenAPI paths.
      class OperationExtractor < Base
        Endpoint = Data.define(:path, :path_item, :operation)

        def call
          document.paths.each do |path, path_item|
            operation = path_item.post
            next unless operation
            next unless webhook_operation?(operation)

            return Endpoint.new(path: path, path_item: path_item, operation: operation)
          end

          nil
        end

        private

        def webhook_operation?(operation)
          operation.operation_id.to_s.match?(/webhook|callback/i) ||
            operation.tags.to_a.any? { |tag| tag.match?(/webhook|callback/i) }
        end
      end
    end
  end
end
