# frozen_string_literal: true

module ProviderIntegrator
  module Model
    # Общая сериализация и глубокая иммутабельность моделей генератора.
    module ValueObject
      # Делает защитную immutable-копию аргументов перед созданием Data object.
      module ImmutableInitializer
        def initialize(**attributes)
          super(**attributes.transform_values { |value| ValueObject.deep_freeze(value) })
        end
      end

      def self.included(base)
        base.prepend(ImmutableInitializer)
      end

      def self.deep_freeze(value)
        case value
        when String
          value.dup.freeze
        when Array
          value.map { |item| deep_freeze(item) }.freeze
        when Hash
          value.to_h { |key, item| [deep_freeze(key), deep_freeze(item)] }.freeze
        else
          value
        end
      end

      def to_h
        self.class.members.to_h do |member|
          [member, serialize(public_send(member))]
        end
      end

      private

      def immutable(value)
        ValueObject.deep_freeze(value)
      end

      def serialize(value)
        case value
        when Array
          value.map { |item| serialize(item) }
        when Hash
          value.to_h { |key, item| [key, serialize(item)] }
        when ValueObject
          value.to_h
        else
          value
        end
      end
    end
  end
end
