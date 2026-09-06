# frozen_string_literal: true

require "provider_integrator"

class Provider
  class SumupRestService < ProviderIntegrator::BaseService
    BASE_URL = ENV.fetch('SUMUP_REST_BASE_URL', 'https://api.sumup.com')

    def check_conditions(_operation, _request_method)
      raise NotImplementedError, "Configure provider conditions"
    end

    def create_request(operation, _request_method = "create")
      payload = build_create_request_payload(operation)
      headers = auth_headers
      response = client.post(
        "#{BASE_URL}/v0.1/checkouts",
        json: payload,
        headers: headers
      )

      parse_create_response(operation, response)
    end

    def process_callback(_payload)
      raise NotImplementedError, "Configure provider callback"
    end

    def fetch_status(operation)
      response = client.get(
        "#{BASE_URL}/v0.1/merchants/#{operation.provider_operation_id}/members/#{operation.provider_operation_id}",
        headers: auth_headers
      )
      return handle_error_response(response) unless [200].include?(response.status.to_i)

      map_status(response.body.fetch("status"))
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

    def build_create_request_payload(operation)
      {
        amount: (operation.amount * 100).to_i
      }
    end

    def parse_create_response(operation, response)
      case response.status.to_i
      when 201
        apply_create_response_mappings(operation, response)
      when 409
        response
      else
        handle_error_response(response)
      end
    end

    def apply_create_response_mappings(operation, response)
      operation.provider_operation_id = response.body.fetch("id")
      operation.status = response.body.fetch("status")
      operation
    end

    def map_status(provider_status)
      STATUS_MAP.fetch(provider_status)
    end
    ERROR_MAP = {
      [400, nil] => {
        internal_code: "validation_error",
        action: :reject,
        retryable: false
      },
      [401, nil] => {
        internal_code: "invalid_credentials",
        action: :block,
        retryable: false
      },
      [403, nil] => {
        internal_code: "provider_error",
        action: :reject,
        retryable: false
      },
      [404, nil] => {
        internal_code: "not_found",
        action: :reject,
        retryable: false
      }
    }.freeze

    STATUS_MAP = {
      "pending" => "in_progress"
    }.freeze
  end
end
