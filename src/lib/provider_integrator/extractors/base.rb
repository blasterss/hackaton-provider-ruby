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
    end
  end
end
