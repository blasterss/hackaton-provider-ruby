# frozen_string_literal: true

module ProviderIntegrator
  module Extractors
    # Извлекает error responses исходящих операций и применяет внутреннюю policy.
    class ErrorMappingExtractor < Base
      STATUS_CODE_POLICIES = {}.freeze

      PROVIDER_CODE_POLICIES = {
        "validation_error" => { internal_code: "validation_error", action: :reject, retryable: false },
        "unauthorized" => { internal_code: "unauthorized", action: :block, retryable: false },
        "insufficient_balance" => { internal_code: "insufficient_balance", action: :retry, retryable: true },
        "not_found" => { internal_code: "not_found", action: :reject, retryable: false },
        "recipient_not_found" => { internal_code: "recipient_not_found", action: :reject, retryable: false },
        "bank_unavailable" => { internal_code: "bank_unavailable", action: :retry, retryable: true },
        "amount_limit_exceeded" => { internal_code: "amount_limit_exceeded", action: :reject, retryable: false },
        "rate_limit_exceeded" => { internal_code: "rate_limit", action: :retry, retryable: true },
        "internal_error" => { internal_code: "internal_error", action: :retry, retryable: true },
        "invalid_status" => { internal_code: "invalid_status", action: :reject, retryable: false }
      }.freeze

      HTTP_STATUS_POLICIES = {
        "400" => { internal_code: "validation_error", action: :reject, retryable: false },
        "401" => { internal_code: "unauthorized", action: :block, retryable: false },
        "402" => { internal_code: "insufficient_balance", action: :retry, retryable: true },
        "404" => { internal_code: "not_found", action: :reject, retryable: false },
        "422" => { internal_code: "validation_error", action: :reject, retryable: false },
        "429" => { internal_code: "rate_limit", action: :retry, retryable: true },
        "500" => { internal_code: "internal_error", action: :retry, retryable: true }
      }.freeze

      CLIENT_ERROR_POLICY = { internal_code: "provider_error", action: :reject, retryable: false }.freeze
      SERVER_ERROR_POLICY = { internal_code: "internal_error", action: :retry, retryable: true }.freeze

      def initialize(document, operations:)
        super(document)
        @operations = operations
      end

      def call
        operations.flat_map { |operation| mappings_for(operation) }
                  .uniq { |mapping| [mapping.http_status, mapping.provider_code] }
      end

      private

      attr_reader :operations

      def mappings_for(operation)
        openapi_operation = document.paths[operation.path]&.public_send(operation.http_method)
        return [] unless openapi_operation

        operation.responses.flat_map do |response_case|
          next [] unless response_case.kind == :error

          response = openapi_operation.responses[response_case.http_status]
          provider_codes(response).filter_map do |provider_code|
            policy = policy_for(response_case.http_status, provider_code)
            build_mapping(response_case.http_status, provider_code, policy) if policy
          end
        end
      end

      def provider_codes(response)
        codes = response_examples(response).filter_map do |example|
          provider_code_from(example)
        end

        codes = unambiguous_schema_codes(response) if codes.empty?
        codes.empty? ? [nil] : codes.map(&:to_s).uniq
      end

      def response_examples(response)
        return [] unless response&.content

        response.content.values.flat_map do |media_type|
          examples = []
          examples << media_type.example if media_type.example
          examples.concat(media_type.examples&.values&.filter_map(&:value) || [])
          examples
        end
      end

      def provider_code_from(example)
        return unless example.is_a?(Hash)

        error = example["error"] || example[:error]
        nested_code = error["code"] || error[:code] if error.is_a?(Hash)
        nested_code || example["code"] || example[:code]
      end

      def unambiguous_schema_codes(response)
        codes = response&.content&.values&.flat_map do |media_type|
          schema = media_type.schema
          error_schema = schema&.properties&.[]("error")
          code_schema = error_schema&.properties&.[]("code") || schema&.properties&.[]("code")
          code_schema&.enum&.to_a || []
        end || []

        unique_codes = codes.uniq
        unique_codes.one? ? unique_codes : []
      end

      def policy_for(http_status, provider_code)
        STATUS_CODE_POLICIES[[http_status, provider_code]] ||
          PROVIDER_CODE_POLICIES[provider_code] ||
          HTTP_STATUS_POLICIES[http_status] ||
          generic_http_policy(http_status)
      end

      def generic_http_policy(http_status)
        status = Integer(http_status, exception: false)
        return CLIENT_ERROR_POLICY if status&.between?(400, 499)
        return SERVER_ERROR_POLICY if status&.between?(500, 599)

        nil
      end

      def build_mapping(http_status, provider_code, policy)
        Model::ErrorMapping.new(
          http_status: http_status.to_i,
          provider_code: provider_code,
          **policy
        )
      end
    end
  end
end
