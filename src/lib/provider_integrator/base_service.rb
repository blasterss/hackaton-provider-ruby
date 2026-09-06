# frozen_string_literal: true

module ProviderIntegrator
  # Базовый контракт для сгенерированных интеграций провайдеров.
  class BaseService
    Result = Data.define(
      :outcome,
      :action,
      :code,
      :provider_operation_id,
      :provider_error_code
    ) do
      def success?
        outcome == :success
      end

      def failed?
        outcome == :failure
      end
    end

    def initialize(client:, credentials:)
      @client = client
      @credentials = credentials
    end

    def check_conditions(_operation, _request_method)
      not_implemented!(:check_conditions)
    end

    def create_request(_operation, _request_method = "create")
      not_implemented!(:create_request)
    end

    def process_callback(_payload)
      not_implemented!(:process_callback)
    end

    def fetch_status(_operation)
      not_implemented!(:fetch_status)
    end

    private

    attr_reader :client, :credentials

    def success
      result(:success)
    end

    def failure(action, code)
      result(:failure, action: action, code: code)
    end

    def approve_operation(provider_operation_id)
      result(
        :success,
        action: :approve,
        provider_operation_id: provider_operation_id
      )
    end

    def reject_operation(provider_operation_id, provider_error_code = nil)
      result(
        :success,
        action: :reject,
        provider_operation_id: provider_operation_id,
        provider_error_code: provider_error_code
      )
    end

    def result(outcome, action: nil, code: nil, provider_operation_id: nil, provider_error_code: nil)
      Result.new(
        outcome: outcome,
        action: action,
        code: code,
        provider_operation_id: provider_operation_id,
        provider_error_code: provider_error_code
      )
    end

    def not_implemented!(method_name)
      raise NotImplementedError, "#{self.class} must implement ##{method_name}"
    end
  end
end
