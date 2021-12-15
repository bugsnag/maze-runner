# frozen_string_literal: true

module Maze
  # Assertion-backed data verification checks
  class AssertCheck < Check
    def true(test, msg = nil)
      assert_true(test, msg)
    end

    def false(test, msg = nil)
      assert_false(test, msg)
    end

    def nil(test, msg = nil)
      assert_nil(test, msg)
    end

    def not_nil(test, msg = nil)
      assert_not_nil(test, msg)
    end

    def match(test, msg = nil)
      assert_match(test, msg)
    end

    def equal(exp, act, msg = nil)
      assert_equal(exp, act, test, msg)
    end

    def not_equal(exp, act, msg = nil)
      assert_not_equal(exp, act, msg)
    end

    def operator(operand1, operator, operand2 = UNDEFINED, msg = nil)
      assert_operator(operand1, operator, operand2, msg)
    end

    def kind_of(cls, obj, msg = nil)
      assert_kind_of(cls, obj, msg = nil)
    end
  end
end
