# frozen_string_literal: true
module Maze
  module Api
    module Model
      # OTEL span kinds.
      module SpanKind
        UNSPECIFIED = 0
        INTERNAL = 1
        SERVER = 2
        CLIENT = 3
        PRODUCER = 4
        CONSUMER = 5
      end
    end
  end
end
