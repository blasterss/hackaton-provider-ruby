# frozen_string_literal: true

module ProviderIntegrator
  module Extractors
    # Базовый интерфейс преобразования OpenAPI document в Integration Model.
    class Base
      attr_reader :document

      def initialize(document)
        @document = document
      end

      def call
        raise NotImplementedError, "#{self.class} must implement #call"
      end

      private

      # Экранирует один сегмент JSON Pointer по RFC 6901.
      def escape_pointer(value)
        value.gsub("~", "~0").gsub("/", "~1")
      end

      # Возвращает параметры с учётом operation-level overrides из OpenAPI.
      def effective_parameters(path_item, operation)
        operation_parameters = operation.parameters.to_a
        overridden_keys = operation_parameters.map { |parameter| parameter_key(parameter) }
        path_parameters = path_item.parameters.to_a.reject do |parameter|
          overridden_keys.include?(parameter_key(parameter))
        end

        path_parameters + operation_parameters
      end

      def parameter_key(parameter)
        [parameter.name, parameter.public_send(:in)]
      end
    end
  end
end
