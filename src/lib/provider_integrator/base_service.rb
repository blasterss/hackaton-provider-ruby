# frozen_string_literal: true

module ProviderIntegrator
  # Базовый контракт для сгенерированных интеграций провайдеров.
  class BaseService
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

    def not_implemented!(method_name)
      raise NotImplementedError, "#{self.class} must implement ##{method_name}"
    end
  end
end
