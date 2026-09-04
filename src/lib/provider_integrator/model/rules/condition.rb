# frozen_string_literal: true

module ProviderIntegrator
  module Model
    # Предварительная проверка operation до обращения к провайдеру.
    #
    # - `field`: путь к проверяемому полю operation.
    # - `operator`: оператор сравнения или проверки.
    # - `value`: ожидаемое или граничное значение.
    # - `unit`: единица измерения значения, если применимо.
    # - `failure_code`: код ошибки при невыполненном условии.
    # - `source_pointer`: источник ограничения в OpenAPI.
    Condition = Data.define(
      :field,
      :operator,
      :value,
      :unit,
      :failure_code,
      :source_pointer
    ) do
      include ValueObject

      def initialize(
        field:,
        operator:,
        value:,
        unit: nil,
        failure_code:,
        source_pointer: nil
      )
        super
      end
    end
  end
end
