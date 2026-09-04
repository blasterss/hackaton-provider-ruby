# frozen_string_literal: true

module ProviderIntegrator
  module Parsers
    class Base
      def parse
        raise NotImplementedError, "#{self.class} must implement #parse"
      end
    end
  end
end
