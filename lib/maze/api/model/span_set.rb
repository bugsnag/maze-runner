# frozen_string_literal: true

require_relative 'span'

module Maze
  module Api
    module Model
      # A collection of spans, typically representing one or more traces.
      class SpanSet
        def initialize
          @spans = {}
        end

        # @param span [Maze::Api::Model::Span] Span to add to the SpanSet.
        def add(span)
          @spans[span.id] = span
        end

        # Add spans from a trace hash to the SpanSet.
        # @param trace_hash [Hash] Trace request payload as a hash.
        def add_from_trace_hash(trace_hash)
          SpanSet.add_trace_hash(trace_hash, self)
        end

        # @param span_id [String] Id of the span to remove from the SpanSet.
        def remove(span_id)
          @spans.delete(span_id)
        end

        # @return [Integer] Number of spans in the SpanSet.
        def size
          @spans.size
        end

        # @return [Array<String>] List of span names in the SpanSet.
        def names
          @spans.values.map(&:name)
        end

        class << self
          # Creates a new SpanSet from a trace hash.
          # @param trace_hash [Hash] Trace request payload as a hash.
          def from_trace_hash(trace_hash)
            span_set = Maze::Api::Model::SpanSet.new
            add_trace_hash(trace_hash, span_set)
            span_set
          end

          # Adds spans from a trace hash to an existing SpanSet.
          # @param trace_hash [Hash] Trace request payload as a hash.
          # @param span_set [Maze::Api::Model::SpanSet] SpanSet to add spans to.
          def add_trace_hash(trace_hash, span_set)
            spans = trace_hash['resourceSpans'].flat_map { |r| r['scopeSpans'] }
                                               .flat_map { |s| s['spans'] }
                                               .select { |s| !s.nil? }

            spans.each do |span_hash|
              span = Maze::Api::Model::Span.from_hash(span_hash)
              span_set.add(span)
            end
          end
        end
      end
    end
  end
end
