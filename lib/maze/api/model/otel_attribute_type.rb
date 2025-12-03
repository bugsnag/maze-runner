# frozen_string_literal: true

module Maze
  module Api
    module Model
      # OTEL attribute types.
      module OtelAttributeType
        ARRAY = 0
        BOOL = 1
        DOUBLE = 2
        INT = 3
        STRING = 4

        # Get the OTEL attribute type constant for a given string.
        # @param type_string [String] OTEL attribute type as a string.
        # @return [Integer, nil] OTEL attribute type constant or nil if not found.
        def self.for_string(type_string)
          case type_string
          when 'arrayValue'
            ARRAY
          when 'boolValue'
            BOOL
          when 'doubleValue'
            DOUBLE
          when 'intValue'
            INT
          when 'stringValue'
            STRING
          else
            nil
          end
        end
      end
    end
  end
end
