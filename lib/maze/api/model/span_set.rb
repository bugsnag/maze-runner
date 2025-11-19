# frozen_string_literal: true

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
      end
    end
  end
end
