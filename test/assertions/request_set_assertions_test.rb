# frozen_string_literal: true

require 'cucumber/core/ast/data_table'
require 'cucumber/multiline_argument/data_table'
require_relative '../test_helper'
require_relative '../../lib/features/support/helper'
require_relative '../../lib/features/support/assertions/request_set_assertions'

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
          'name' => 'Brian',
          'age' => 22,
          'town' => 'Bournemouth'
        }
      },
      {
        body: {
          'name' => 'Brian',
          'age' => 30,
          'town' => 'Blandford'
        }
      },
      {
        body: {
          'name' => 'Camilla',
          'age' => 133,
          'town' => 'Coventry'
        }
      }
    ]
  end

  def create_table(rows)
    headered_rows = [%w[name age town]]
    rows.each { |row| headered_rows.append(row) }

    data = Cucumber::Core::Ast::DataTable.new headered_rows, nil
    Cucumber::MultilineArgument::DataTable.new data
  end

  def test_simple_match
    rows = [
      %w[Camilla 133 Coventry]
    ]
    matches = RequestSetAssertions.matching_rows @requests, create_table(rows)
    assert_equal({ 0 => 3 }, matches)
  end
end
