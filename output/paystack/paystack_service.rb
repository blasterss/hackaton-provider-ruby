# frozen_string_literal: true

require "provider_integrator"

class Provider
  class PaystackService < ProviderIntegrator::BaseService
    BASE_URL = ENV.fetch('PAYSTACK_BASE_URL', 'https://api.paystack.co')

    def check_conditions(_operation, _request_method)
      raise NotImplementedError, "Configure provider conditions"
    end

    def create_request(_operation, _request_method = "create")
      raise NotImplementedError, "Configure create request operation"
    end

    def process_callback(_payload)
      raise NotImplementedError, "Configure provider callback"
    end

    def fetch_status(_operation)
      raise NotImplementedError, "Configure status operation"
    end

    private

    def auth_headers
      { "Authorization" => "Bearer " + credentials.fetch(:access_token) }
    end

    def error_mapping(http_status, provider_code = nil)
      status = http_status.to_i
      ERROR_MAP.fetch([status, provider_code]) do
        ERROR_MAP.fetch([status, nil], nil)
      end
    end

    def handle_error_response(response)
      mapping = error_mapping(response.status, provider_error_code(response))
      return failure(:reject, "provider.unknown_error") unless mapping

      failure(mapping.fetch(:action), "provider.#{mapping.fetch(:internal_code)}")
    end

    def provider_error_code(response)
      body = response.body
      return unless body.is_a?(Hash)

      error = body["error"] || body[:error]
      return error["code"] || error[:code] if error.is_a?(Hash)

      body["code"] || body[:code]
    end

    def apply_create_response_mappings(operation, response)
      operation.status = response.body.fetch("status")
      operation
    end
    ERROR_MAP = {
      [401, nil] => {
        internal_code: "invalid_credentials",
        action: :block,
        retryable: false
      },
      [400, nil] => {
        internal_code: "validation_error",
        action: :reject,
        retryable: false
      },
      [404, nil] => {
        internal_code: "not_found",
        action: :reject,
        retryable: false
      },
      [422, nil] => {
        internal_code: "validation_error",
        action: :reject,
        retryable: false
      }
    }.freeze

  end
end
