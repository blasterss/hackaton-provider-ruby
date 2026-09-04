# frozen_string_literal: true

require "fileutils"

module ProviderIntegrator
  module Generators
    # Собирает минимальный Ruby service из Integration Model.
    class ServiceGenerator < Base
      TEMPLATE = "ruby/service.rb.erb"
      BLOCKS = {
        constants: [],
        public_methods: [
          "ruby/blocks/conditions/base.rb.erb",
          "ruby/blocks/requests/base.rb.erb",
          "ruby/blocks/callbacks/base.rb.erb",
          "ruby/blocks/statuses/base.rb.erb"
        ],
        private_methods: ["ruby/blocks/authentication/base.rb.erb"]
      }.freeze

      def initialize(renderer: Renderers::Base.new)
        @renderer = renderer
      end

      def call(integration, output_dir: "output")
        content = renderer.render(
          TEMPLATE,
          locals: { integration: integration },
          blocks: BLOCKS
        )

        write(output_dir, "#{integration.provider.slug}_service.rb", content)
      end

      private

      attr_reader :renderer
    end
  end
end
