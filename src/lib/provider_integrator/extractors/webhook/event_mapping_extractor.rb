# frozen_string_literal: true

module ProviderIntegrator
  module Extractors
    module Webhook
      # Преобразует enum событий webhook в действия над внутренней операцией.
      class EventMappingExtractor < Base
        EVENT_ACTIONS = {
          "completed" => :approve,
          "failed" => :reject,
          "cancelled" => :reject,
          "processing" => :ignore
        }.freeze

        def initialize(document, operation:)
          super(document)
          @operation = operation
        end

        def call
          schema = payload_schema
          return [] unless schema

          operation_id_path = operation_id_path(schema)
          return [] unless operation_id_path

          event_values(schema).filter_map do |event|
            action = action_for(event)
            next unless action

            Model::EventMapping.new(
              event: event,
              action: action,
              operation_id_path: operation_id_path,
              error_code_path: error_code_path(schema, action)
            )
          end
        end

        private

        attr_reader :operation

        def payload_schema
          operation.request_body&.content&.[]("application/json")&.schema
        end

        def event_values(schema)
          schema.properties&.[]("event")&.enum&.to_a || []
        end

        def action_for(event)
          EVENT_ACTIONS.find { |suffix, _action| event.to_s.end_with?(suffix) }&.last
        end

        def operation_id_path(schema)
          property = %w[payout_id operation_id external_id].find { |name| schema.properties&.keys&.include?(name) }
          "payload.#{property}" if property
        end

        def error_code_path(schema, action)
          return unless action == :reject

          error_schema = schema.properties&.[]("error")
          "payload.error.code" if error_schema&.properties&.keys&.include?("code")
        end
      end
    end
  end
end
