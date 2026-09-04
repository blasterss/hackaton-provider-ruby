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
    end
  end
end
