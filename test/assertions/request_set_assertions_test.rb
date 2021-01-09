# frozen_string_literal: true

require 'cucumber/core/ast/data_table'
require 'cucumber/multiline_argument/data_table'
require_relative '../test_helper'
require_relative '../../lib/maze/helper'
require_relative '../../lib/maze/assertions/request_set_assertions'

class RequestSetAssertionsTest < Test::Unit::TestCase

  def setup
    @requests = [
      {
        body: {
          'name' => 'Alice',
          'age' => 11,
          'town' => 'Arkansas'
        }
      },
      {
        body: {
          'name' => 'Bret',
          'age' => 22,
          'town' => 'Birmingham'
        }
      },
      {
        body: {
          'name' => 'Bret',
          'age' => 23,
          'town' => 'Houston'
        }
      },
      {
        body: {
          'name' => 'Camilla',
          'age' => 33,
          'town' => 'New York'
        }
      }
    ]
  end

  def create_table(header, rows)
    headered_rows = [header]
    rows.each { |row| headered_rows.append(row) }

    data = Cucumber::Core::Ast::DataTable.new headered_rows, nil
    Cucumber::MultilineArgument::DataTable.new data
  end

  def test_simple_match
    header = %w[name age town]
    rows = [
      ['Camilla', '33', 'New York']
    ]
    matches = Maze::Assertions::RequestSetAssertions.matching_rows @requests, create_table(header, rows)
    assert_equal({ 0 => 3 }, matches)
  end

  def test_simple_no_match
    header = %w[name age town]
    rows = [
        %w[Camilla 33 'York']
    ]
    matches = Maze::Assertions::RequestSetAssertions.matching_rows @requests, create_table(header, rows)
    assert_equal({}, matches)
  end

  def test_all_match
    header = %w[name age town]
    rows = [
      ['Camilla', '33', 'New York'],
      %w[Bret 22 Birmingham],
      %w[Alice 11 Arkansas],
      %w[Bret 23 Houston],
    ]
    matches = Maze::Assertions::RequestSetAssertions.matching_rows @requests, create_table(header, rows)
    assert_equal({ 0 => 3, 1 => 1, 2 => 0, 3 => 2 }, matches)
  end

  def test_one_column
    header = ['age']
    rows = [
      ['33'],
      ['22'],
      ['11'],
      ['23']
    ]
    matches = Maze::Assertions::RequestSetAssertions.matching_rows @requests, create_table(header, rows)
    assert_equal({ 0 => 3, 1 => 1, 2 => 0, 3 => 2 }, matches)
  end

  def test_regexp
    header = %w[name age town]
    rows = [
      %w[Bret 22 /ming/]
    ]
    matches = Maze::Assertions::RequestSetAssertions.matching_rows @requests, create_table(header, rows)
    assert_equal({ 0 => 1 }, matches)
  end

  def test_multiple_rows_same
    header = ['name']
    rows = [
      ['Bret'],
      ['Bret']
    ]
    matches = Maze::Assertions::RequestSetAssertions.matching_rows @requests, create_table(header, rows)
    # Order unimportant, but it must find two different requests
    assert_equal(2, matches.length)
    assert_not_equal(matches[0], matches[1])
  end
end
