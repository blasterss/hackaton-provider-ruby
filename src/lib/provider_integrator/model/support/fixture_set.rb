# frozen_string_literal: true

module ProviderIntegrator
  module Model
    # Примеры запросов и ответов для выходного файла fixtures.json.
    #
    # - `create_request`: примеры создания операции.
    # - `fetch_status`: примеры запроса статуса.
    # - `callbacks`: примеры входящих callback.
    FixtureSet = Data.define(
      :create_request,
      :fetch_status,
      :callbacks
    ) do
      include ValueObject

      def initialize(create_request: {}, fetch_status: {}, callbacks: [])
        super(
          create_request: immutable(create_request),
          fetch_status: immutable(fetch_status),
          callbacks: immutable(callbacks)
        )
      end
    end
  end
end
