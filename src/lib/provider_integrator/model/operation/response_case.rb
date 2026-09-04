# frozen_string_literal: true

module ProviderIntegrator
  module Model
    # Вариант ответа конкретной HTTP-операции.
    #
    # - `http_status`: HTTP status или OpenAPI-значение `default`.
    # - `kind`: семантика ответа `:success`, `:duplicate` или `:error`.
    # - `field_mappings`: правила чтения успешного ответа.
    # - `error_mapping`: правило обработки ошибочного ответа.
    ResponseCase = Data.define(
      :http_status,
      :kind,
      :field_mappings,
      :error_mapping
    ) do
      include ValueObject

      def initialize(http_status:, kind:, field_mappings: [], error_mapping: nil)
        super(
          http_status: http_status,
          kind: kind,
          field_mappings: immutable(field_mappings),
          error_mapping: error_mapping
        )
      end
    end
  end
end
