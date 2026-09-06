# frozen_string_literal: true

require "openapi3_parser"

module ProviderIntegrator
  module Parsers
    class Error < StandardError
    end

    class InaccessibleSpecificationError < Error
    end

    class InvalidSpecificationError < Error
      DEFAULT_ERROR_LIMIT = 10

      attr_reader :errors

      def initialize(errors, limit: DEFAULT_ERROR_LIMIT)
        @errors = errors
        @limit = limit
        super(build_message(errors))
      end

      private

      attr_reader :limit

      def build_message(errors)
        error_list = errors.to_h
        display_errors = error_list.first(limit)

        lines = display_errors.map do |path, messages|
          "#{path}: #{Array(messages).join(", ")}"
        end

        remaining_count = error_list.size - display_errors.size
        lines << "...and #{remaining_count} more errors" if remaining_count.positive?

        "OpenAPI specification is invalid:\n#{lines.join("\n")}"
      end
    end

    class Openapi < Base
      attr_reader :path

      def initialize(path)
        @path = File.expand_path(path)
      end

      def call
        raw_document = OpenapiLoader.new(path).call
        normalization = OpenapiNormalizer.new(raw_document).call

        document = Openapi3Parser.load(normalization.document)

        unless document.valid?
          raise InvalidSpecificationError.new(document.errors)
        end

        document
      rescue Openapi3Parser::Error::InaccessibleInput => error
        raise InaccessibleSpecificationError, error.message
      end
    end
  end
end
