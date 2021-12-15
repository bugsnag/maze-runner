# frozen_string_literal: true

module Maze
  # Base class for data verification checks.  This is designed to be an abstraction on top of Minitest::Assertions,
  # allowing checks to be implemented in different ways (e.g. no op and delayed fail).
  class Check
    def true(test, msg = nil); end

    def false(test, msg = nil); end

    def nil(test, msg = nil); end

    def not_nil(test, msg = nil); end

    def match(test, msg = nil); end

    def equal(exp, act, msg = nil); end

    def not_equal(exp, act, msg = nil); end

    def operator(operand1, operator, operand2 = UNDEFINED, msg = nil); end

    def kind_of(cls, obj, msg = nil); end
  end
end
