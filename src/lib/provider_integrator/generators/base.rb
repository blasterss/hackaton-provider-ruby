# frozen_string_literal: true

require "fileutils"

module ProviderIntegrator
  module Generators
    # Общие операции записи сгенерированных артефактов.
    class Base
      private

      def write(output_dir, provider_slug, filename, content)
        provider_dir = File.join(output_dir, provider_slug)
        FileUtils.mkdir_p(provider_dir)
        path = File.join(provider_dir, filename)
        File.write(path, content)
        path
      end
    end
  end
end
