# frozen_string_literal: true

require "erb"

module ProviderIntegrator
  module Renderers
    # Отрисовывает корневой ERB-шаблон и выбранные generator partial-блоки.
    class Base
      TEMPLATE_ROOT = File.expand_path("../../../templates", __dir__)

      def initialize(template_root: TEMPLATE_ROOT)
        @template_root = template_root
      end

      def render(template, locals: {}, blocks: {})
        source = File.read(template_path(template))
        context = Context.new(self, locals, blocks)

        ERB.new(source, trim_mode: "-").result(context.binding)
      end

      private

      attr_reader :template_root

      def template_path(template)
        File.join(template_root, template)
      end

      # Binding с данными Integration Model и доступом к partial-блокам.
      class Context
        def initialize(renderer, locals, blocks)
          @renderer = renderer
          @locals = locals
          @blocks = blocks
        end

        def render_blocks(group)
          @blocks.fetch(group, []).map do |template|
            @renderer.render(template, locals: @locals)
          end.join("\n")
        end

        def binding
          local_binding = Kernel.binding
          @locals.each { |name, value| local_binding.local_variable_set(name, value) }
          local_binding
        end
      end
    end
  end
end
