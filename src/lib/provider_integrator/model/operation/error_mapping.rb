# frozen_string_literal: true

module ProviderIntegrator
  module Model
    # Сопоставление ответа с ошибкой и дальнейшим действием интеграции.
    #
    # - `http_status`: HTTP status ответа провайдера.
    # - `provider_code`: машинный код ошибки провайдера.
    # - `internal_code`: нормализованный внутренний код ошибки.
    # - `action`: действие `reject`, `retry`, `alert` или `block`.
    # - `retryable`: разрешено ли повторить запрос.
    ErrorMapping = Data.define(
      :http_status,
      :provider_code,
      :internal_code,
      :action,
      :retryable
    ) do
      include ValueObject

      def initialize(
        http_status:,
        provider_code: nil,
        internal_code:,
        action:,
        retryable: false
      )
        super
      end
    end
  end
end
