# frozen_string_literal: true

module ProviderIntegrator
  module Extractors
    module Webhook
      # Координирует небольшие webhook-extractors и собирает Webhook Model.
      class Extractor < Base
        def call
          endpoint = OperationExtractor.new(document).call
          return unless endpoint

          Model::Webhook.new(
            path: endpoint.path,
            signature: SignatureExtractor.new(document, operation: endpoint.operation).call,
            event_mappings: EventMappingExtractor.new(document, operation: endpoint.operation).call,
            source_pointer: "/paths/#{escape_pointer(endpoint.path)}/post"
          )
        end

        private

        def escape_pointer(value)
          value.gsub("~", "~0").gsub("/", "~1")
        end
      end
    end
  end
end
