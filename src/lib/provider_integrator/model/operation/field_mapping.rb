# frozen_string_literal: true

module ProviderIntegrator
  module Model
    # Правило переноса одного значения между operation и payload провайдера.
    #
    # - `target_path`: путь поля в результирующей структуре.
    # - `source_path`: путь к исходному значению.
    # - `transform`: разрешённое преобразование значения.
    # - `required`: является ли поле обязательным.
    # - `value`: константное значение для transform `:constant`.
    FieldMapping = Data.define(
      :target_path,
      :source_path,
      :transform,
      :required,
      :value
    ) do
      include ValueObject

      def initialize(
        target_path:,
        source_path: nil,
        transform: :identity,
        required: false,
        value: nil
      )
        super
      end
    end
  end
end
