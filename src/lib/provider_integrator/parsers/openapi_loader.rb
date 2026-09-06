# frozen_string_literal: true

require "yaml"
require "date"
require "time"

module ProviderIntegrator
  module Parsers
    class OpenapiLoader
      def initialize(path)
        @path = path
      end

      def call
        document = YAML.safe_load_file(
          @path,
          permitted_classes: [Date, Time],
          aliases: true
        )

        normalize_yaml_values(document)
      end

      private

      def normalize_yaml_values(value)
        case value
        when Hash
          value.each_with_object({}) do |(key, child), result|
            result[key] = normalize_yaml_values(child)
          end
        when Array
          value.map { |child| normalize_yaml_values(child) }
        when Time, Date
          value.iso8601
        else
          value
        end
      end
    end
  end
end
