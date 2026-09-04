# frozen_string_literal: true

module ProviderIntegrator
  module Model
    # Правило формирования path, header или query-параметра HTTP-запроса.
    #
    # - `name`: имя параметра в API провайдера.
    # - `location`: расположение `:path`, `:header` или `:query`.
    # - `source_path`: путь к исходному значению в operation.
    # - `transform`: разрешённое преобразование значения.
    # - `required`: является ли параметр обязательным.
    # - `value`: константное значение, если источник не используется.
    RequestParameter = Data.define(
      :name,
      :location,
      :source_path,
      :transform,
      :required,
      :value
    ) do
      include ValueObject

      def initialize(
        name:,
        location:,
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
