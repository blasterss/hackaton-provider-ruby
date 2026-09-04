# frozen_string_literal: true

module ProviderIntegrator
  module Model
    # Связывает событие webhook с действием над внутренней операцией.
    #
    # - `event`: значение event в callback payload.
    # - `action`: действие, например `:approve`, `:reject` или `:ignore`.
    # - `operation_id_path`: путь к идентификатору операции в payload.
    # - `error_code_path`: путь к коду ошибки для reject-события.
    EventMapping = Data.define(
      :event,
      :action,
      :operation_id_path,
      :error_code_path
    ) do
      include ValueObject

      def initialize(
        event:,
        action:,
        operation_id_path:,
        error_code_path: nil
      )
        super
      end
    end
  end
end
