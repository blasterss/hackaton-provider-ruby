# frozen_string_literal: true

module ProviderIntegrator
  module Generators
    # Генерирует INTEGRATION.md из нормализованной Integration Model.
    class DocumentationGenerator < Base
      TEMPLATE = "documentation/integration.md.erb"
      SECTIONS = {
        authentication: ["documentation/sections/authentication.md.erb"],
        endpoints: ["documentation/sections/endpoints.md.erb"],
        status_mapping: ["documentation/sections/status_mapping.md.erb"],
        error_handling: ["documentation/sections/error_handling.md.erb"],
        gateway_config: ["documentation/sections/gateway_config.md.erb"],
        webhook_signature: ["documentation/sections/webhook_signature.md.erb"]
      }.freeze

      def initialize(renderer: Renderers::Base.new)
        @renderer = renderer
      end

      def call(integration, output_dir: "output")
        content = renderer.render(
          TEMPLATE,
          locals: {
            integration: integration,
            documentation_view: DocumentationView.new(integration)
          },
          blocks: SECTIONS
        )

        write(output_dir, integration.provider.slug, "INTEGRATION.md", content)
      end

      private

      attr_reader :renderer
    end
  end
end
