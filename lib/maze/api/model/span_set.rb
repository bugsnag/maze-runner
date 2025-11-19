# frozen_string_literal: true

require_relative 'span'

module Maze
  module Api
    module Model
      class SpanSet
        def initialize
          @spans = {}
        end

        def add(span)
          @spans[span.id] = span
        end

        def remove(span)
          @spans.delete(span.id)
        end

        def size
          @spans.size
        end

        def names
          @spans.values.map(&:name)
        end

        class << self
          def from_trace_hash(trace_hash)
            span_set = Maze::Api::Model::SpanSet.new

            spans = trace_hash['resourceSpans'].flat_map { |r| r['scopeSpans'] }
              .flat_map { |s| s['spans'] }
              .select { |s| !s.nil? }

            spans.each do |span_hash|
              span = Maze::Api::Model::Span.from_hash(span_hash)
              span_set.add(span)
            end

            span_set
          end
        end
      end
    end
  end
end
