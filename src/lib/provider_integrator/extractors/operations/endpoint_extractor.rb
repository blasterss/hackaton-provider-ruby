# frozen_string_literal: true

module ProviderIntegrator
  module Extractors
    module Operations
      # Перечисляет HTTP-операции, которым удалось назначить поддерживаемую роль.
      class EndpointExtractor < Base
        HTTP_METHODS = %i[get post put patch delete].freeze
        Endpoint = Data.define(:role, :path, :path_item, :http_method, :operation)

        def call
          document.paths.flat_map do |path, path_item|
            HTTP_METHODS.filter_map do |http_method|
              operation = path_item.public_send(http_method)
              next unless operation

              role = RoleExtractor.new(
                document,
                path: path,
                path_item: path_item,
                http_method: http_method,
                operation: operation
              ).call
              build_endpoint(role, path, path_item, http_method, operation) if role
            end
          end
        end

        private

        def build_endpoint(role, path, path_item, http_method, operation)
          Endpoint.new(
            role: role,
            path: path,
            path_item: path_item,
            http_method: http_method,
            operation: operation
          )
        end
      end
    end
  end
end
