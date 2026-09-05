# frozen_string_literal: true

module ProviderIntegrator
  module Extractors
    # Извлекает поддерживаемые исходящие операции из OpenAPI paths.
    class OperationsExtractor < Base
      def call
        endpoint = fetch_status_endpoint
        endpoint ? [build_fetch_status(*endpoint)] : []
      end

      private

      def fetch_status_endpoint
        document.paths.each do |path, path_item|
          operation = path_item.get
          next unless operation
          next unless fetch_status_operation?(operation)

          return [path, path_item, operation]
        end

        nil
      end

      def fetch_status_operation?(operation)
        operation.operation_id.to_s.match?(/status/i) || response_contains_status?(operation)
      end

      def response_contains_status?(operation)
        success_response(operation)&.content&.values&.any? do |media_type|
          media_type.schema&.properties&.keys&.include?("status")
        end
      end

      def success_response(operation)
        operation.responses.find { |status, _response| status.start_with?("2") }&.last
      end

      def build_fetch_status(path, path_item, operation)
        Model::Operation.new(
          role: :fetch_status,
          http_method: :get,
          path: path,
          operation_id: operation.operation_id,
          parameters: path_parameters(path_item, operation),
          responses: response_cases(operation),
          source_pointer: "/paths/#{escape_pointer(path)}/get"
        )
      end

      def path_parameters(path_item, operation)
        [*path_item.parameters, *operation.parameters]
          .select { |parameter| parameter.public_send(:in) == "path" }
          .map do |parameter|
            Model::RequestParameter.new(
              name: parameter.name,
              location: :path,
              source_path: "operation.provider_operation_id",
              transform: :to_string,
              required: parameter.required?
            )
          end
      end

      def response_cases(operation)
        operation.responses.map do |status, _response|
          Model::ResponseCase.new(
            http_status: status,
            kind: status.start_with?("2") ? :success : :error
          )
        end
      end
    end
  end
end
