# frozen_string_literal: true

module ProviderIntegrator
  module Model
    # Исходящая HTTP-операция, привязанная к роли сервисного контракта.
    #
    # - `role`: роль, например `:create_request` или `:fetch_status`.
    # - `http_method`: HTTP-метод в нижнем регистре.
    # - `path`: шаблон пути endpoint.
    # - `operation_id`: исходный `operationId` из OpenAPI.
    # - `parameters`: параметры path, headers и query string.
    # - `request_fields`: поля исходящего payload.
    # - `responses`: варианты успешных и ошибочных ответов.
    # - `source_pointer`: JSON Pointer на операцию в OpenAPI.
    Operation = Data.define(
      :role,
      :http_method,
      :path,
      :operation_id,
      :parameters,
      :request_fields,
      :responses,
      :source_pointer
    ) do
      include ValueObject

      def initialize(
        role:,
        http_method:,
        path:,
        operation_id: nil,
        parameters: [],
        request_fields: [],
        responses: [],
        source_pointer: nil
      )
        super(
          role: role,
          http_method: http_method,
          path: path,
          operation_id: operation_id,
          parameters: immutable(parameters),
          request_fields: immutable(request_fields),
          responses: immutable(responses),
          source_pointer: source_pointer
        )
      end
    end
  end
end
