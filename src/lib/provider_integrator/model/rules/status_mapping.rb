# frozen_string_literal: true

module ProviderIntegrator
  module Model
    # Сопоставление статуса провайдера со статусом Space Payments.
    #
    # - `provider_status`: статус во внешнем API.
    # - `internal_status`: статус внутренней операции.
    StatusMapping = Data.define(
      :provider_status,
      :internal_status
    ) do
      include ValueObject
    end
  end
end
