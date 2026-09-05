# frozen_string_literal: true

require "json"

module ProviderIntegrator
  module Generators
    # Подготавливает Integration Model к отрисовке руководства по интеграции.
    class DocumentationView
      AUTHENTICATION_TYPES = {
        api_key: "API Key",
        bearer: "Bearer Token"
      }.freeze
      OPERATION_PURPOSES = {
        create_request: "Создание операции",
        fetch_status: "Получение статуса",
        cancel: "Отмена операции",
        fetch_balance: "Получение баланса"
      }.freeze

      def initialize(integration)
        @integration = integration
      end

      def authentication_type
        type = integration.authentication.type
        AUTHENTICATION_TYPES.fetch(type, humanize(type))
      end

      def authentication_value
        authentication = integration.authentication
        reference = "<credentials.#{authentication.credential_key}>"
        return "Bearer #{reference}" if authentication.type == :bearer

        reference
      end

      def operation_name(operation)
        operation.operation_id || operation.role
      end

      def operation_purpose(operation)
        OPERATION_PURPOSES.fetch(operation.role, humanize(operation.role))
      end

      def idempotency_parameter(operation)
        parameter = operation.parameters.find do |candidate|
          candidate.location == :header && candidate.name.match?(/idempoten/i)
        end
        parameter ? "#{parameter.name} header" : "—"
      end

      def gateway_config
        return unless integration.gateway_config

        JSON.generate(integration.gateway_config.to_h)
      end

      def signature_algorithm
        integration.webhook.signature.algorithm.to_s.upcase.tr("_", "-")
      end

      def signature_encoding
        integration.webhook.signature.encoding || ServiceView::DEFAULT_CALLBACK_SIGNATURE_ENCODING
      end

      private

      attr_reader :integration

      def humanize(value)
        value.to_s.split("_").map(&:capitalize).join(" ")
      end
    end
  end
end
