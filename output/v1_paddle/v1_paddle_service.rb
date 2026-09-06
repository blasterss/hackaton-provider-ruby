# frozen_string_literal: true

require "provider_integrator"

class Provider
  class V1PaddleService < ProviderIntegrator::BaseService
    BASE_URL = ENV.fetch('V1_PADDLE_BASE_URL', 'https://api.paddle.com')

    def check_conditions(_operation, _request_method)
      raise NotImplementedError, "Configure provider conditions"
    end

    def create_request(operation, _request_method = "create")
      payload = build_create_request_payload(operation)
      headers = auth_headers
      response = client.post(
        "#{BASE_URL}/transactions",
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
        "#{BASE_URL}/transactions/#{operation.provider_operation_id}",
        headers: auth_headers
      )
      return response unless [200].include?(response.status.to_i)

      map_status(response.body.dig("data", "status"))
    end

    private

    def auth_headers
      { "Authorization" => "Bearer " + credentials.fetch(:access_token) }
    end

    def build_create_request_payload(operation)
      {
        items: operation.items
      }
    end

    def parse_create_response(operation, response)
      case response.status.to_i
      when 201
        apply_create_response_mappings(operation, response)
      else
        handle_error_response(response)
      end
    end

    def apply_create_response_mappings(operation, response)
      operation.provider_operation_id = response.body.dig("data", "id")
      operation
    end

    def map_status(provider_status)
      STATUS_MAP.fetch(provider_status)
    end
    STATUS_MAP = {
      "draft" => "in_progress",
      "ready" => "in_progress",
      "billed" => "in_progress",
      "paid" => "approved",
      "completed" => "approved",
      "canceled" => "rejected",
      "past_due" => "rejected"
    }.freeze
  end
end
