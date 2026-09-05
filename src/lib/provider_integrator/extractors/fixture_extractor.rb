# frozen_string_literal: true

module ProviderIntegrator
  module Extractors
    # Собирает fixtures только из явно заданных OpenAPI example/examples.
    class FixtureExtractor < Base
      def initialize(document, operations:, webhook: nil)
        super(document)
        @operations = operations
        @webhook = webhook
      end

      def call
        Model::FixtureSet.new(
          create_request: operation_fixtures(:create_request),
          fetch_status: operation_fixtures(:fetch_status),
          callbacks: callback_fixtures
        )
      end

      private

      attr_reader :operations, :webhook

      def operation_fixtures(role)
        operation = operations.find { |candidate| candidate.role == role }
        return {} unless operation

        openapi_operation = document.paths[operation.path]&.public_send(operation.http_method)
        return {} unless openapi_operation

        request_examples(openapi_operation).merge(response_examples(openapi_operation))
      end

      def request_examples(operation)
        media_type = operation.request_body&.content&.[]("application/json")
        named_examples(media_type, "request")
      end

      def response_examples(operation)
        operation.responses.each_with_object({}) do |(status, response), fixtures|
          media_type = response.content&.[]("application/json")
          fixtures.merge!(named_examples(media_type, "response_#{status}"))
        end
      end

      def callback_fixtures
        return [] unless webhook

        operation = document.paths[webhook.path]&.post
        media_type = operation&.request_body&.content&.[]("application/json")
        example_values(media_type)
      end

      def named_examples(media_type, prefix)
        examples = example_entries(media_type)
        return {} if examples.empty?
        return { prefix => examples.first.last } if examples.one?

        examples.to_h { |name, value| ["#{prefix}_#{name}", value] }
      end

      def example_values(media_type)
        example_entries(media_type).map(&:last)
      end

      def example_entries(media_type)
        return [] unless media_type
        return [["example", media_type.example]] unless media_type.example.nil?

        media_type.examples&.map { |name, example| [name, example.value] } || []
      end
    end
  end
end
