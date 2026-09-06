# frozen_string_literal: true

module ProviderIntegrator
  module Extractors
    # Проверяет полноту извлечённой модели и сообщает о потерянных данных OpenAPI.
    class DiagnosticExtractor < Base
      PROVIDER_ID_TARGET = "operation.provider_operation_id"

      def initialize(document, operations:, webhook:, status_mappings:, fixtures:)
        super(document)
        @operations = operations
        @webhook = webhook
        @status_mappings = status_mappings
        @fixtures = fixtures
      end

      def call
        diagnostics = []
        diagnostics.concat(operation_diagnostics)
        diagnostics.concat(create_request_diagnostics)
        diagnostics.concat(webhook_diagnostics)
        diagnostics.concat(status_diagnostics)
        diagnostics.concat(fixture_diagnostics)
        diagnostics
      end

      private

      attr_reader :operations, :webhook, :status_mappings, :fixtures

      def operation_diagnostics
        diagnostics = []
        unless operation(:create_request)
          diagnostics << diagnostic(:error, :missing_create_request, "Create request operation was not found")
        end
        unless operation(:fetch_status)
          diagnostics << diagnostic(:warning, :missing_fetch_status, "Fetch status operation was not found")
        end
        diagnostics << diagnostic(:warning, :missing_webhook, "Webhook operation was not found") unless webhook
        diagnostics
      end

      def create_request_diagnostics
        create_request = operation(:create_request)
        return [] unless create_request

        diagnostics = unmapped_required_fields(create_request).map do |field|
          diagnostic(
            :warning,
            :unmapped_required_request_field,
            "Required create request field is not mapped: #{field}",
            create_request.source_pointer
          )
        end
        return diagnostics if provider_operation_id_mapped?(create_request)

        diagnostics << diagnostic(
          :error,
          :missing_provider_operation_id,
          "Successful create response does not map provider operation ID",
          create_request.source_pointer
        )
      end

      def webhook_diagnostics
        return [] unless webhook

        diagnostics = []
        if webhook.signature.nil?
          diagnostics << diagnostic(
            :warning,
            :missing_webhook_signature,
            "Webhook signature was not detected",
            webhook.source_pointer
          )
        elsif webhook.signature.encoding.nil?
          diagnostics << diagnostic(
            :warning,
            :missing_webhook_signature_encoding,
            "Webhook signature encoding was not detected",
            webhook.source_pointer
          )
        end
        if webhook.event_mappings.empty?
          diagnostics << diagnostic(
            :warning,
            :missing_webhook_events,
            "Webhook event mappings were not detected",
            webhook.source_pointer
          )
        end
        diagnostics
      end

      def status_diagnostics
        fetch_status = operation(:fetch_status)
        return [] unless fetch_status

        provider_statuses(fetch_status).filter_map do |status|
          next if status_mappings.any? { |mapping| mapping.provider_status == status }

          diagnostic(
            :warning,
            :unmapped_provider_status,
            "Provider status is not mapped: #{status}",
            fetch_status.source_pointer
          )
        end
      end

      def fixture_diagnostics
        diagnostics = []
        create_request = operation(:create_request)
        fetch_status = operation(:fetch_status)
        if create_request && !success_fixture?(fixtures.create_request)
          diagnostics << diagnostic(
            :warning,
            :missing_create_success_example,
            "Create request has no successful response example",
            create_request.source_pointer
          )
        end
        if fetch_status && !success_fixture?(fixtures.fetch_status)
          diagnostics << diagnostic(
            :warning,
            :missing_fetch_status_success_example,
            "Fetch status has no successful response example",
            fetch_status.source_pointer
          )
        end
        if webhook && fixtures.callbacks.empty?
          diagnostics << diagnostic(
            :warning,
            :missing_webhook_examples,
            "Webhook has no request examples",
            webhook.source_pointer
          )
        end
        diagnostics
      end

      def operation(role)
        operations.find { |candidate| candidate.role == role }
      end

      def unmapped_required_fields(create_request)
        openapi_operation = document.paths[create_request.path]&.post
        schema = openapi_operation&.request_body&.content&.[]("application/json")&.schema
        required = schema&.required&.to_a || []
        mapped_roots = create_request.request_fields.map { |mapping| mapping.target_path.split(".").first }.uniq
        required - mapped_roots
      end

      def provider_operation_id_mapped?(create_request)
        create_request.responses.any? do |response|
          response.kind == :success && response.field_mappings.any? do |mapping|
            mapping.target_path == PROVIDER_ID_TARGET
          end
        end
      end

      def provider_statuses(fetch_status)
        openapi_operation = document.paths[fetch_status.path]&.public_send(fetch_status.http_method)
        explicit_mappings = extension_hash(openapi_operation, "x-provider-integrator-status-mappings")
        return explicit_mappings.keys.map(&:to_s) if explicit_mappings.any?

        success_schemas(openapi_operation).flat_map do |schema|
          schema.properties&.[]("status")&.enum&.to_a || []
        end.uniq
      end

      def success_fixture?(fixture_set)
        fixture_set.keys.any? { |key| key.match?(/\Aresponse_2/) }
      end

      def diagnostic(severity, code, message, source_pointer = nil)
        Model::Diagnostic.new(
          severity: severity,
          code: code,
          message: message,
          source_pointer: source_pointer
        )
      end
    end
  end
end
