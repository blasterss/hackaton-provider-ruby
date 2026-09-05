# frozen_string_literal: true

require_relative "provider_integrator/parsers/base"
require_relative "provider_integrator/parsers/openapi"
require_relative "provider_integrator/base_service"
require_relative "provider_integrator/model"
require_relative "provider_integrator/extractors"
require_relative "provider_integrator/renderers"
require_relative "provider_integrator/generators"
require_relative "provider_integrator/cli"

module ProviderIntegrator
  def self.build(spec_path)
    document = Parsers::Openapi.new(spec_path).parse
    Extractors::IntegrationExtractor.new(document).call
  end

  def self.generate(spec_path, output_dir: "output")
    integration = build(spec_path)
    [
      Generators::ServiceGenerator,
      Generators::DocumentationGenerator,
      Generators::FixtureGenerator
    ].map do |generator|
      generator.new.call(integration, output_dir: output_dir)
    end
  end
end
