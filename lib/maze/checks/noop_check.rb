# frozen_string_literal: true

module Maze
  module Checks
    # Assertion-backed data verification checks
    class NoopCheck
      def true(_test, _message = nil) end

      def false(_test, _message = nil) end

      def nil(_test, _message = nil) end

      def not_nil(_test, _message = nil) end

      def match(_pattern, _string, _message = nil) end

      def equal(_expected, _actual, _message = nil) end

      def not_equal(_expected, _actual, _message = nil) end

      def operator(_operand1, _operator, _operand2, _message = nil) end

      def kind_of(_klass, _object, _message = nil) end

      def block(_message = 'block failed', &_block) end

      def include(_collection, _object, _message = nil) end
      alias includes include

      def not_include(_collection, _object, _message = nil) end
      alias not_includes not_include
    end
  end
end
