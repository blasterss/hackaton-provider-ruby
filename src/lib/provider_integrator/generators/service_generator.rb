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
          "ruby/blocks/callbacks/base.rb.erb"
        ],
        private_methods: ["ruby/blocks/authentication/base.rb.erb"]
      }.freeze

      def initialize(renderer: Renderers::Base.new)
        @renderer = renderer
      end

      def call(integration, output_dir: "output")
        service_view = ServiceView.new(integration)
        content = renderer.render(
          TEMPLATE,
          locals: { integration: integration, service_view: service_view },
          blocks: blocks_for(integration)
        )

        write(output_dir, "#{integration.provider.slug}_service.rb", content)
      end

      private

      attr_reader :renderer

      def blocks_for(integration)
        error_blocks = error_blocks_for(integration)
        request_blocks = request_blocks_for(integration)
        status_blocks = status_blocks_for(integration)

        BLOCKS.to_h do |group, templates|
          [
            group,
            templates + error_blocks.fetch(group) + request_blocks.fetch(group) + status_blocks.fetch(group)
          ]
        end
      end

      def error_blocks_for(integration)
        if integration.error_mappings.any?
          {
            constants: ["ruby/blocks/errors/constants.rb.erb"],
            public_methods: [],
            private_methods: ["ruby/blocks/errors/map.rb.erb"]
          }
        else
          {
            constants: [],
            public_methods: [],
            private_methods: []
          }
        end
      end

      def request_blocks_for(integration)
        if create_request_supported?(integration)
          {
            constants: [],
            public_methods: ["ruby/blocks/requests/create.rb.erb"],
            private_methods: [
              "ruby/blocks/requests/payload.rb.erb",
              "ruby/blocks/requests/response.rb.erb"
            ]
          }
        else
          {
            constants: [],
            public_methods: ["ruby/blocks/requests/base.rb.erb"],
            private_methods: []
          }
        end
      end

      def status_blocks_for(integration)
        if status_supported?(integration)
          {
            constants: ["ruby/blocks/statuses/constants.rb.erb"],
            public_methods: ["ruby/blocks/statuses/fetch.rb.erb"],
            private_methods: ["ruby/blocks/statuses/map.rb.erb"]
          }
        else
          {
            constants: [],
            public_methods: ["ruby/blocks/statuses/base.rb.erb"],
            private_methods: []
          }
        end
      end

      def status_supported?(integration)
        integration.operations.any? { |operation| operation.role == :fetch_status } &&
          integration.status_mappings.any?
      end

      def create_request_supported?(integration)
        operation = integration.operations.find { |candidate| candidate.role == :create_request }
        operation && operation.request_fields.any?
      end
    end
  end
end
