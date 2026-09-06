# frozen_string_literal: true

require_relative "provider_integrator/parsers/base"
require_relative "provider_integrator/parsers/openapi_loader"
require_relative "provider_integrator/parsers/openapi_normalizer"
require_relative "provider_integrator/parsers/openapi"
require_relative "provider_integrator/base_service"
require_relative "provider_integrator/model"
require_relative "provider_integrator/extractors"
require_relative "provider_integrator/renderers"
require_relative "provider_integrator/generators"
require_relative "provider_integrator/cli"

module ProviderIntegrator
  class << self
    def build(spec_path)
      document = Parsers::Openapi.new(spec_path).call
      unless document.valid?
        raise Parsers::Error, format_errors(document.errors)
      end

      Extractors::IntegrationExtractor.new(document).call
    rescue Openapi3Parser::Error => exception
      raise Parsers::Error, "OpenAPI parsing failed: #{exception.message}"
    end

    def generate(spec_path, output_dir: "output")
      integration = build(spec_path)
      [
        Generators::ServiceGenerator,
        Generators::DocumentationGenerator,
        Generators::FixtureGenerator
      ].map do |generator|
        generator.new.call(integration, output_dir: output_dir)
      end
    end

    private

    def format_errors(error_collection)
      errors =
        if error_collection.respond_to?(:to_h)
          error_collection.to_h
        elsif error_collection.respond_to?(:errors)
          error_collection.errors
        else
          return "OpenAPI specification is invalid:\n#{error_collection.inspect}"
        end

      lines = ["OpenAPI specification is invalid:"]

      errors.each do |path, messages|
        Array(messages).each do |message|
          lines << "  #{path}: #{message}"
        end
      end

      lines.join("\n")
    end
  end
end
