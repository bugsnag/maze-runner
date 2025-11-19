# frozen_string_literal: true
require_relative 'span_attribute_type'

module Maze
  module Api
    module Model
      class SpanAttributeArrayElement
        attr_accessor :type, :value

        def initialize(type, value)
          @type = type
          @value = value
        end
      end

      class SpanAttribute
        attr_accessor :type, :key, :value

        def initialize(type, key, value)
          @key = key
          @type = type
          @value = value
        end

        class << self
          def array_from_hash(hash_array)
            array = []
            hash_array['values'].each do |value_hash|
              type = SpanAttributeType::for_string(value_hash.keys.first)
              value = value_hash.values.first
              array << SpanAttributeArrayElement.new(type, value)
            end
          end

          def from_hash(hash)
            type = SpanAttributeType::for_string(hash['value'].keys.first)
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
