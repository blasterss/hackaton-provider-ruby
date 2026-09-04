# frozen_string_literal: true

module ProviderIntegrator
  module Model
    # Сообщение о неполных или неоднозначных данных спецификации.
    #
    # - `severity`: уровень `:info`, `:warning` или `:error`.
    # - `code`: стабильный машинный код сообщения.
    # - `message`: понятное разработчику описание проблемы.
    # - `source_pointer`: связанное место в OpenAPI.
    Diagnostic = Data.define(
      :severity,
      :code,
      :message,
      :source_pointer
    ) do
      include ValueObject

      def initialize(severity:, code:, message:, source_pointer: nil)
        super
      end
    end
  end
end
