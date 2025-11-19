# frozen_string_literal: true
require_relative 'otel_attribute_type'

module Maze
  module Api
    module Model
      class OtelAttributeArrayElement
        attr_accessor :type, :value

        def initialize(type, value)
          @type = type
          @value = value
        end
      end

      # OTEL attributes used in both spans and resources
      class OtelAttribute
        attr_accessor :type, :key, :value

        def initialize(type, key, value)
          @key = key
          @type = type
          @value = value
        end

        class << self
          def array_from_hash(hash_array)
            array = []
            hash_array.each do |value_hash|
              type = OtelAttributeType::for_string(value_hash.keys.first)
              value = value_hash.values.first
              array << OtelAttributeArrayElement.new(type, value)
            end
            array
          end

          def from_hash(hash)
            type = OtelAttributeType.for_string(hash['value'].keys.first)
            hash_value = hash['value']
            value = if hash_value.has_key?('arrayValue')
              array_from_hash(hash_value['arrayValue']['values'])
            elsif hash_value.has_key?('boolValue')
              hash_value['boolValue']
            elsif hash_value.has_key?('doubleValue')
              hash_value['doubleValue']
            elsif hash_value.has_key?('intValue')
              hash_value['intValue']
            elsif hash_value.has_key?('stringValue')
              hash_value['stringValue']
            end

            new(
              type,
              hash['key'],
              value
            )
          end
        end
      end
    end
  end
end
