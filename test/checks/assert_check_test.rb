# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../lib/maze/checks/assert_check'

class AssertCheckTest < Test::Unit::TestCase
  # Strings are interpreted as regexes
  def test_match_string
    pattern = "Hello,*"
    value = "Hello, World"
    check = Maze::Checks::AssertCheck.new
    check.match pattern, value
  end

  # Rexexp objects can be passed directly to match
  def test_match_regexp
    pattern = /Hello,*/
    value = "Hello, World"
    check = Maze::Checks::AssertCheck.new
    check.match pattern, value
  end
end
