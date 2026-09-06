# frozen_string_literal: true

require "provider_integrator"
require "openssl"

class Provider
  class NovapayService < ProviderIntegrator::BaseService
    BASE_URL = ENV.fetch('NOVAPAY_BASE_URL', 'https://api.novapay.example/v1')

    def check_conditions(operation, _request_method)
      if operation.amount < 1000
        return failure(:unprocessable_entity, "amount_too_low")
      end

      success
    end

    def create_request(operation, _request_method = "create")
      payload = build_create_request_payload(operation)
      headers = auth_headers
      headers["Idempotency-Key"] = operation.id.to_s
      response = client.post(
        "#{BASE_URL}/payouts",
        json: payload,
        headers: headers
      )

      parse_create_response(operation, response)
    end

    def process_callback(payload, raw_body:, headers:)
      verify_callback_signature!(raw_body, headers)

      case payload.fetch("event")
      when "payout.completed"
        approve_operation(payload.fetch("payout_id"))
      when "payout.failed"
        reject_operation(payload.fetch("payout_id"), payload.dig("error", "code"))
      when "payout.processing"
        success
      when "payout.cancelled"
        reject_operation(payload.fetch("payout_id"), payload.dig("error", "code"))
      else
        failure(:unprocessable_entity, "unknown_event")
      end
    end

    def fetch_status(operation)
      response = client.get(
        "#{BASE_URL}/payouts/#{operation.provider_operation_id}",
        headers: auth_headers
      )
      return handle_error_response(response) unless [200].include?(response.status.to_i)

      map_status(response.body.fetch("status"))
    end

    private

    def auth_headers
      { "X-API-Key" => credentials.fetch(:api_key) }
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
        amount: (operation.amount * 100).to_i,
        currency: "RUB",
        external_id: operation.id.to_s,
        recipient: {
          type: "sbp",
          phone: operation.payout_requisite.dig("sbp", "phone"),
          bank_code: operation.payout_requisite.dig("sbp", "bank_code"),
          bank_name: operation.payout_requisite.dig("sbp", "bank_name")
        }
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

    def verify_callback_signature!(raw_body, headers)
      digest = OpenSSL::HMAC.digest(
        "SHA256",
        credentials.fetch(:callback_secret),
        raw_body
      )
      expected = digest.unpack1("H*")
      actual = headers.fetch("X-NovaPay-Signature")

      return true if expected.bytesize == actual.bytesize &&
                     OpenSSL.fixed_length_secure_compare(expected, actual)

      raise SecurityError, "Invalid webhook signature"
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
      [401, "unauthorized"] => {
        internal_code: "invalid_credentials",
        action: :block,
        retryable: false
      },
      [402, "insufficient_balance"] => {
        internal_code: "insufficient_balance",
        action: :retry,
        retryable: true
      },
      [422, "validation_error"] => {
        internal_code: "validation_error",
        action: :reject,
        retryable: false
      },
      [429, "rate_limit_exceeded"] => {
        internal_code: "rate_limit",
        action: :retry,
        retryable: true
      },
      [500, nil] => {
        internal_code: "internal_error",
        action: :retry,
        retryable: true
      },
      [404, "not_found"] => {
        internal_code: "not_found",
        action: :reject,
        retryable: false
      },
      [409, "invalid_status"] => {
        internal_code: "invalid_status",
        action: :reject,
        retryable: false
      }
    }.freeze

    STATUS_MAP = {
      "pending" => "in_progress",
      "processing" => "in_progress",
      "completed" => "approved",
      "failed" => "rejected",
      "cancelled" => "rejected"
    }.freeze
  end
end
