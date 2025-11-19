# frozen_string_literal: true

require_relative 'span_attribute'

module Maze
  module Api
    module Model
      class Span
        attr_accessor :id, :kind, :name, :trace_id, :start_time, :end_time, :attributes

        def initialize
          @attributes = {}

          def add_attribute(attribute)
            @attributes[attribute.key] = attribute
          end
        end

        class << self
          def from_hash(hash)
            span = new
            span.id = hash['spanId']
            span.kind = hash['kind']
            span.name = hash['name']
            span.trace_id = hash['traceId']
            span.start_time = hash['startTimeUnixNano']
            span.end_time = hash['endTimeUnixNano']

            hash['attributes'].each do |attribute_hash|
              attribute = SpanAttribute.from_hash(attribute_hash)
              span.add_attribute(attribute)
            end

            span
          end
        end
      end
    end
  end
end
