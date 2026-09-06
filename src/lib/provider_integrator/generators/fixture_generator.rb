# frozen_string_literal: true

require "json"

module ProviderIntegrator
  module Generators
    # Генерирует fixtures.json из примеров, извлечённых в Integration Model.
    class FixtureGenerator < Base
      TEMPLATE = "fixtures/fixtures.json.erb"

      def initialize(renderer: Renderers::Base.new)
        @renderer = renderer
      end

      def call(integration, output_dir: "output")
        content = renderer.render(TEMPLATE, locals: { integration: integration })
        write(output_dir, integration.provider.slug, "fixtures.json", content)
      end

      private

      attr_reader :renderer
    end
  end
end
