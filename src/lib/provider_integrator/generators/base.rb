# frozen_string_literal: true

require "fileutils"

module ProviderIntegrator
  module Generators
    # Общие операции записи сгенерированных артефактов.
    class Base
      private

      def write(output_dir, filename, content)
        FileUtils.mkdir_p(output_dir)
        path = File.join(output_dir, filename)
        File.write(path, content)
        path
      end
    end
  end
end
