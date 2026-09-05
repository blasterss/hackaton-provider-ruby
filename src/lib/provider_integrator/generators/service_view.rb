# frozen_string_literal: true

module ProviderIntegrator
  module Generators
    # Подготавливает Integration Model к отрисовке Ruby service templates.
    class ServiceView
      # Временный fallback для спецификаций без явно указанного encoding подписи.
      DEFAULT_CALLBACK_SIGNATURE_ENCODING = :hex

      class UnsupportedMappingError < StandardError
      end

      def initialize(integration)
        @integration = integration
      end

      def operation(role)
        integration.operations.find { |operation| operation.role == role }
      end

      def payload_source(mappings, indent: 6)
        render_hash(mapping_tree(mappings), indent)
      end

      def value_expression(mapping)
        return ruby_literal(mapping.value) if mapping.transform == :constant

        source = source_expression(mapping.source_path)
        case mapping.transform
        when :identity
          source
        when :to_string
          "#{source}.to_s"
        when :major_to_minor
          "(#{source} * 100).to_i"
        else
          raise UnsupportedMappingError, "Unsupported mapping transform: #{mapping.transform}"
        end
      end

      def response_assignment(mapping)
        target = direct_attribute_expression(mapping.target_path)
        "#{target} = #{value_expression(mapping)}"
      end

      def condition_failure_expression(condition)
        field = source_expression(condition.field)
        value = ruby_literal(condition.value)

        case condition.operator
        when :greater_than_or_equal
          "#{field} < #{value}"
        when :greater_than
          "#{field} <= #{value}"
        when :less_than_or_equal
          "#{field} > #{value}"
        when :less_than
          "#{field} >= #{value}"
        when :equal
          "#{field} != #{value}"
        else
          raise UnsupportedMappingError, "Unsupported condition operator: #{condition.operator}"
        end
      end

      def callback_action_expression(mapping)
        operation_id = payload_expression(mapping.operation_id_path)

        case mapping.action
        when :approve
          "approve_operation(#{operation_id})"
        when :reject
          arguments = [operation_id, payload_expression(mapping.error_code_path)].compact
          "reject_operation(#{arguments.join(", ")})"
        when :ignore
          "success"
        else
          raise UnsupportedMappingError, "Unsupported callback action: #{mapping.action}"
        end
      end

      def callback_signature_supported?
        signature = integration.webhook&.signature
        signature&.algorithm == :hmac_sha256 && %i[hex base64].include?(callback_signature_encoding)
      end

      def callback_signature_digest
        case callback_signature_encoding
        when :hex
          'digest.unpack1("H*")'
        when :base64
          '[digest].pack("m0")'
        else
          raise UnsupportedMappingError,
                "Unsupported signature encoding: #{callback_signature_encoding}"
        end
      end

      private

      attr_reader :integration

      def callback_signature_encoding
        integration.webhook&.signature&.encoding || DEFAULT_CALLBACK_SIGNATURE_ENCODING
      end

      def mapping_tree(mappings)
        mappings.each_with_object({}) do |mapping, root|
          segments = mapping.target_path.split(".")
          leaf = segments.pop
          branch = segments.reduce(root) { |current, segment| current[segment] ||= {} }
          branch[leaf] = mapping
        end
      end

      def render_hash(node, indent)
        entries = node.map do |key, value|
          rendered_value = value.is_a?(Hash) ? render_hash(value, indent + 2) : value_expression(value)
          "#{" " * (indent + 2)}#{ruby_hash_key(key)} #{rendered_value}"
        end

        body = entries.each_with_index.map do |entry, index|
          index == entries.length - 1 ? entry : "#{entry},"
        end
        (["{"] + body + ["#{" " * indent}}"]).join("\n")
      end

      def ruby_hash_key(key)
        key.match?(/\A[a-zA-Z_]\w*\z/) ? "#{key}:" : "#{key.dump} =>"
      end

      def ruby_literal(value)
        value.inspect
      end

      def source_expression(path)
        raise UnsupportedMappingError, "Mapping source path is missing" unless path

        root, attribute, *nested = path.split(".")
        case root
        when "operation"
          expression = "operation.#{attribute}"
          nested.empty? ? expression : "#{expression}.dig(#{nested.map(&:dump).join(", ")})"
        when "response"
          response_body_expression([attribute, *nested])
        else
          raise UnsupportedMappingError, "Unsupported mapping source: #{path}"
        end
      end

      def response_body_expression(segments)
        return "response.body.fetch(#{segments.first.dump})" if segments.one?

        "response.body.dig(#{segments.map(&:dump).join(", ")})"
      end

      def payload_expression(path)
        return unless path

        root, *segments = path.split(".")
        if root != "payload" || segments.empty?
          raise UnsupportedMappingError, "Unsupported callback payload path: #{path}"
        end
        return "payload.fetch(#{segments.first.dump})" if segments.one?

        "payload.dig(#{segments.map(&:dump).join(", ")})"
      end

      def direct_attribute_expression(path)
        root, attribute, *nested = path.split(".")
        if root != "operation" || attribute.nil? || nested.any?
          raise UnsupportedMappingError, "Unsupported mapping target: #{path}"
        end

        "operation.#{attribute}"
      end
    end
  end
end
