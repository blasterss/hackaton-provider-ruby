# frozen_string_literal: true

require_relative "provider_integrator/parsers/base"
require_relative "provider_integrator/parsers/openapi"
require_relative "provider_integrator/base_service"
require_relative "provider_integrator/model"
require_relative "provider_integrator/extractors"
require_relative "provider_integrator/renderers"
require_relative "provider_integrator/generators"

module ProviderIntegrator
  def self.generate(spec_path, slug:, output_dir: "output")
    document = Parsers::Openapi.new(spec_path).parse
    integration = Extractors::IntegrationExtractor.new(document, slug: slug).call

    Generators::ServiceGenerator.new.call(integration, output_dir: output_dir)
  end
end
