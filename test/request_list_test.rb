# frozen_string_literal: true

require 'test_helper'
require_relative '../lib/maze/request_list'

# noinspection RubyNilAnalysis
class RequestListTest < Test::Unit::TestCase

  def build_item(id)
    {
      id: id,
      request: {
        body: "{id: '#{id}'}"
      }
    }
  end

  def build_item_with_header(id, time)
    header = 'Bugsnag-Sent-At'
    {
      id: id,
      request: {
        header => time,
        body: "{id: '#{id}'}"
      }
    }
  end

  def test_fresh_state
    list = Maze::RequestList.new
    assert_nil list.current
    assert_empty list
    assert_equal 0, list.size
    assert_equal [], list.all
  end

  def test_add_and_next
    list = Maze::RequestList.new

    # Add 2
    item1 = build_item 1
    item2 = build_item 2
    list.add item1
    list.add item2

    # Check current and state
    assert_not_empty list
    assert_equal 2, list.size
    assert_equal item1, list.current
    assert_not_equal item2, list.current
    assert_equal [item1, item2], list.all

    # Next => item2
    list.next
    assert_equal item2, list.current
    assert_equal [item1, item2], list.all

    # Next => nil
    list.next
    assert_nil list.current
  end

  def test_add_after_next
    item1 = build_item 1
    item2 = build_item 2
    item3 = build_item 3
    item4 = build_item 4
    item5 = build_item 5

    list = Maze::RequestList.new
    list.add item1
    list.add item2
    list.add item3
    list.next
    list.next

    assert_equal item3, list.current

    list.add item4
    list.add item5
    assert_equal item3, list.current

    list.next
    assert_equal item4, list.current
  end

  def test_clear
    item1 = build_item 1
    item2 = build_item 2
    item3 = build_item 3

    list = Maze::RequestList.new
    list.add item1
    list.add item2
    list.add item3
    assert_equal [item1, item2, item3], list.all
    list.next
    list.next
    assert_equal item3, list.current

    list.clear
    assert_equal [], list.all
    assert_nil list.current

    # Re-ddd something - checks internal pointer was reset
    list.add item1
    assert_equal item1, list.current
  end

  def test_too_many_nexts
    item1 = build_item 1
    item2 = build_item 2

    list = Maze::RequestList.new
    list.add item1

    3.times { list.next }
    assert_nil list.current

    list.add item2
    assert_equal item2, list.current
  end

  def test_remaining
    item1 = build_item 1
    item2 = build_item 2
    item3 = build_item 3

    list = Maze::RequestList.new
    list.add item1
    list.add item2
    list.add item3

    list.next
    remaining = list.remaining
    assert_equal [item2, item3], remaining

    # Check that remaining does not change when inspected
    remaining = list.remaining
    assert_equal [item2, item3], remaining
  end

  def test_sort_by_all_requests
    time1 = '2021-02-21T15:00:00.001Z'
    time2 = '2021-01-21T14:00:00.000Z'
    time3 = '2021-02-21T15:00:00.000Z'

    request1 = build_item_with_header 1, time1
    request2 = build_item_with_header 2, time2
    request3 = build_item_with_header 3, time3

    list = Maze::RequestList.new
    list.add request1
    list.add request2
    list.add request3

    list.sort_by_sent_at! 3

    assert_equal [request2, request3, request1], list.remaining
  end

  def test_sort_by_missing header
    time1 = '2021-02-21T15:00:00.001Z'
    time2 = '2021-02-21T15:00:00.000Z'

    request1 = build_item_with_header 1, time1
    request2 = build_item 2
    request3 = build_item_with_header 3, time2

    list = Maze::RequestList.new
    list.add request1
    list.add request2
    list.add request3

    list.sort_by_sent_at! 3

    assert_equal [request1, request2, request3], list.remaining
  end

  def test_sort_by_remaining_requests
    time1 = '2021-02-21T15:00:00.001Z'
    time2 = '2021-01-21T14:00:00.000Z'
    time3 = '2021-02-21T15:00:00.000Z'

    request1 = build_item 1
    request2 = build_item_with_header 2, time1
    request3 = build_item_with_header 3, time2
    request4 = build_item_with_header 4, time3

    list = Maze::RequestList.new
    list.add request1
    list.add request2
    list.add request3
    list.next
    list.add request4

    list.sort_by_sent_at! 3

    assert_equal [request3, request4, request2], list.remaining
  end

  def test_sort_by_with_subsequent_request
    time1 = '2021-02-21T15:00:00.001Z'
    time2 = '2021-01-21T14:00:00.000Z'
    time3 = '2021-02-21T15:00:00.000Z'

    request1 = build_item 1
    request2 = build_item_with_header 2, time1 # Sort
    request3 = build_item_with_header 3, time2 # Sort
    request4 = build_item_with_header 4, time3 # Do not sort
    request5 = build_item 5 # No header, but out of scope

    list = Maze::RequestList.new
    list.add request1
    list.add request2
    list.add request3
    list.next
    list.add request4
    list.add request5

    list.sort_by_sent_at! 2

    assert_equal [request3, request2, request4, request5], list.remaining
  end
end
