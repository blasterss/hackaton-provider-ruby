# frozen_string_literal: true

module ProviderIntegrator
  module Model
    # Описание входящего webhook и правил обработки его событий.
    #
    # - `path`: endpoint, на который провайдер отправляет callback.
    # - `signature`: правило проверки подписи callback.
    # - `event_mappings`: сопоставления событий с действиями.
    # - `source_pointer`: JSON Pointer на webhook в OpenAPI.
    Webhook = Data.define(
      :path,
      :signature,
      :event_mappings,
      :source_pointer
    ) do
      include ValueObject

      def initialize(
        path:,
        signature: nil,
        event_mappings: [],
        source_pointer: nil
      )
        super(
          path: path,
          signature: signature,
          event_mappings: immutable(event_mappings),
          source_pointer: source_pointer
        )
      end
    end
  end
end
