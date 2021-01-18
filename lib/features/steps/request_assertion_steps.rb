# frozen_string_literal: true

require 'test/unit'
require 'minitest'
require 'open-uri'
require 'json'
require 'cgi'
require_relative '../../maze/wait'

include Test::Unit::Assertions

# @!group Request assertion steps

def assert_received_requests(request_count, list, list_name)
  timeout = Maze.config.receive_requests_wait
  wait = Maze::Wait.new(timeout: timeout)

  received = wait.until { list.size >= request_count }

  unless received
    raise <<-MESSAGE
    Expected #{request_count} #{list_name} but received #{list.size} within the #{timeout}s timeout.
    This could indicate that:
    - Bugsnag crashed with a fatal error.
    - Bugsnag did not make the requests that it should have done.
    - The requests were made, but not deemed to be valid (e.g. missing integrity header).
    - The requests made were prevented from being received due to a network or other infrastructure issue.
    Please check the Maze Runner and device logs to confirm.)
    MESSAGE
  end

  assert_equal(request_count, list.size, "#{list.size} #{list_name} received")
end

#
# Error request assertions
#
# Shortcut to waiting to receive a single request of the given type
#
# @step_input request_type [String] The type of request (error, session, etc)
Then('I wait to receive a(n) {word}') do |request_type|
  step "I wait to receive 1 #{request_type}"
end

# Continually checks to see if the required amount of requests have been received.
# Times out according to @see Maze.config.receive_requests_wait.
#
# @step_input request_type [String] The type of request (error, session, etc)
# @step_input request_count [Integer] The amount of requests expected
Then('I wait to receive {int} {word}') do |request_count, request_type|
  assert_received_requests request_count, Maze::Server.list_for(request_type), request_type
end

# Assert that the test Server hasn't received any requests - of a specific, or any, type.
#
# @step_input request_type [String] The type of request ('error', 'session', etc), or 'requests' to assert on all
#   request types.
Then('I should receive no {word}') do |request_type|
  sleep Maze.config.receive_no_requests_wait
  if request_type == 'requests'
    # Assert that the test Server hasn't received any requests at all.
    assert_equal(0, Maze::Server.errors.size, "#{Maze::Server.errors.size} errors received")
    assert_equal(0, Maze::Server.sessions.size, "#{Maze::Server.sessions.size} sessions received")
  else
    list = Maze::Server.list_for(request_type).size
    assert_equal(0, list, "#{list.size} #{request_type} received")
  end
end

# Moves to the next request
#
# @step_input request_type [String] The type of request (error, session, etc)
Then('I discard the oldest {word}') do |request_type|
  raise "No #{request_type} to discard" if Maze::Server.list_for(request_type).current.nil?

  Maze::Server.list_for(request_type).next
end

Then('the received errors match:') do |table|
  # Checks that each request matches one of the event fields
  requests = Maze::Server.errors.remaining
  match_count = 0

  # iterate through each row in the table. exactly 1 request should match each row.
  table.hashes.each do |row|
    requests.each do |request|
      # Skip if no body.events in this request
      next if (!request.key? :body) || (!request[:body].key? 'events')

      events = request[:body]['events']
      assert_equal(1, events.length, 'Expected exactly one event per request')
      match_count += 1 if request_matches_row(events[0], row)
    end
  end
  assert_equal(requests.size, match_count, 'Unexpected number of requests matched the received payloads')
end
