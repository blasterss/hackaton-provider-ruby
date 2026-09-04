# frozen_string_literal: true

module ProviderIntegrator
  module Model
    # Правило добавления credentials в запрос к API провайдера.
    #
    # - `type`: тип авторизации, например `:api_key` или `:bearer`.
    # - `location`: место передачи credentials: `:header` или `:query`.
    # - `parameter_name`: имя HTTP-заголовка или query-параметра.
    # - `credential_key`: ключ значения в credentials провайдера.
    Authentication = Data.define(
      :type,
      :location,
      :parameter_name,
      :credential_key
    ) do
      include ValueObject
    end
  end
end
