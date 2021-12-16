# frozen_string_literal: true

module Maze
  # Assertion-backed data verification checks
  class NoopCheck
    def true(_test, _message = nil) end

    def false(_test, _message = nil) end

    def nil(_test, _message = nil) end

    def not_nil(_test, _message = nil) end

    def match(_test, _message = nil) end

    def equal(_expected, _actual, _message = nil) end

    def not_equal(_expected, _actual, _message = nil) end

    def operator(_operand1, _operator, _operand2, _message = nil) end

    def kind_of(_klass, _object, _message = nil) end
  end
end
