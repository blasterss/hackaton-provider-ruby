# frozen_string_literal: true

module ProviderIntegrator
  module Model
    # Правило проверки криптографической подписи webhook.
    #
    # - `algorithm`: алгоритм, например `:hmac_sha256`.
    # - `header`: заголовок, содержащий подпись.
    # - `secret_key`: ключ секрета в credentials провайдера.
    # - `encoding`: представление подписи, например `:hex` или `:base64`.
    Signature = Data.define(
      :algorithm,
      :header,
      :secret_key,
      :encoding
    ) do
      include ValueObject
    end
  end
end
