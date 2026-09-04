# frozen_string_literal: true

module ProviderIntegrator
  module Model
    # Полное нормализованное описание будущей интеграции провайдера.
    #
    # - `provider`: идентификационные данные провайдера.
    # - `gateway_config`: настройки подключения ProviderGateway.
    # - `authentication`: правило авторизации запросов.
    # - `operations`: исходящие API-операции.
    # - `webhook`: описание входящих callback.
    # - `conditions`: предварительные проверки operation.
    # - `status_mappings`: сопоставления статусов.
    # - `error_mappings`: правила обработки ошибок.
    # - `fixtures`: примеры для генерируемого fixtures.json.
    # - `diagnostics`: найденные warnings и ошибки.
    Integration = Data.define(
      :provider,
      :gateway_config,
      :authentication,
      :operations,
      :webhook,
      :conditions,
      :status_mappings,
      :error_mappings,
      :fixtures,
      :diagnostics
    ) do
      include ValueObject

      def initialize(
        provider:,
        gateway_config: nil,
        authentication: nil,
        operations: [],
        webhook: nil,
        conditions: [],
        status_mappings: [],
        error_mappings: [],
        fixtures: {},
        diagnostics: []
      )
        super(
          provider: provider,
          gateway_config: gateway_config,
          authentication: authentication,
          operations: immutable(operations),
          webhook: webhook,
          conditions: immutable(conditions),
          status_mappings: immutable(status_mappings),
          error_mappings: immutable(error_mappings),
          fixtures: immutable(fixtures),
          diagnostics: immutable(diagnostics)
        )
      end
    end
  end
end
