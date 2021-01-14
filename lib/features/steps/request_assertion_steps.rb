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

# Assert that the test Server hasn't received any requests at all.
Then('I should receive no requests') do
  sleep Maze.config.receive_no_requests_wait
  assert_equal(0, Maze::Server.errors.size, "#{Maze::Server.errors.size} errors received")
  assert_equal(0, Maze::Server.sessions.size, "#{Maze::Server.sessions.size} sessions received")
end

#
# Error request assertions
#
# Shortcut to waiting to receive a single error
Then('I wait to receive an error') do
  step 'I wait to receive 1 error'
end

# Continually checks to see if the required amount of errors have been received.
# Times out according to @see Maze.config.receive_requests_wait.
#
# @step_input request_count [Integer] The amount of requests expected
Then('I wait to receive {int} error(s)') do |request_count|
  assert_received_requests request_count, Maze::Server.errors, 'errors'
end

# Assert that the test Server hasn't received any errors.
Then('I should receive no errors') do
  sleep Maze.config.receive_no_requests_wait
  assert_equal(0, Maze::Server.errors.size, "#{Maze::Server.errors.size} errors received")
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

#
# Session request assertions
#

# Shortcut to waiting to receive a single session
Then('I wait to receive a session') do
  step 'I wait to receive 1 session'
end

# Moves to the next error
Then('I discard the oldest error') do
  raise 'No error to discard' if Maze::Server.errors.current.nil?

  Maze::Server.errors.next
end

# Continually checks to see if the required amount of sessions have been received.
# Times out according to @see Maze.config.receive_requests_wait.
#
# @step_input request_count [Integer] The amount of requests expected
Then('I wait to receive {int} session(s)') do |request_count|
  assert_received_requests request_count, Maze::Server.sessions, 'sessions'
end

# Assert that the test Server hasn't received any sessions.
Then('I should receive no sessions') do
  sleep Maze.config.receive_no_requests_wait
  assert_equal(0, Maze::Server.sessions.size, "#{Maze::Server.sessions.size} sessions received")
end

# Moves to the next sessions
Then('I discard the oldest session') do
  raise 'No session to discard' if Maze::Server.sessions.current.nil?

  Maze::Server.sessions.next
end
