# frozen_string_literal: true

module ProviderIntegrator
  module Model
    # Настройки ProviderGateway для подключения сгенерированного сервиса.
    #
    # - `external_method`: внешний платёжный метод провайдера.
    # - `gateway`: внутренний идентификатор шлюза Space Payments.
    GatewayConfig = Data.define(
      :external_method,
      :gateway
    ) do
      include ValueObject
    end
  end
end
