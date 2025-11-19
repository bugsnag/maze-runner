# frozen_string_literal: true

module Maze
  module Api
    module Model
      module SpanAttributeType
        ARRAY = 0
        BOOL = 1
        DOUBLE = 2
        INT = 3
        STRING = 4

        def for_string(type_string)
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
