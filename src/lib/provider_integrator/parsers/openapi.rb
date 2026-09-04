# frozen_string_literal: true

require "openapi3_parser"

module ProviderIntegrator
  module Parsers
    class Error < StandardError
    end

    class InaccessibleSpecificationError < Error
    end

    class InvalidSpecificationError < Error
      attr_reader :errors

      def initialize(errors)
        @errors = errors
        super("OpenAPI specification is invalid: #{errors}")
      end
    end

    class Openapi < Base
      attr_reader :path

      def initialize(path)
        @path = File.expand_path(path)
      end

      def parse
        document = Openapi3Parser.load_file(path)
        raise InvalidSpecificationError, document.errors unless document.valid?

        document
      rescue Openapi3Parser::Error::InaccessibleInput => error
        raise InaccessibleSpecificationError, error.message
      end
    end
  end
end
