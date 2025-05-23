# frozen_string_literal: true

require 'test/unit'
require 'open-uri'
require 'json'
require 'cgi'
require_relative '../../maze/wait'

# @!group Request assertion steps

def assert_received_requests(request_count, list, list_name, precise = true, maximum = nil)
  timeout = Maze.config.receive_requests_wait
  # Interval set to 0.5s to make it more likely to detect erroneous extra requests,
  # without impacting overall speed too much
  wait = Maze::Wait.new(interval: 0.5, timeout: timeout)

  last_count = 0
  start_time = Time.now
  received = wait.until do

    count_now = list.size_remaining
    elapsed = Time.now - start_time
    if elapsed > Maze.config.receive_requests_slow_threshold
      if count_now > last_count
        $logger.warn "Received #{count_now - last_count} request(s) after #{elapsed.round(1)}s"
      end
    end
    last_count = count_now
    count_now >= request_count
  end

  unless received
    raise Test::Unit::AssertionFailedError.new <<-MESSAGE
    Expected #{request_count} #{list_name} but received #{list.size_remaining} within the #{timeout}s timeout.
    This could indicate that:
    - Bugsnag crashed with a fatal error.
    - Bugsnag did not make the requests that it should have done.
    - The requests were made, but not deemed to be valid (e.g. missing integrity header).
    - The requests made were prevented from being received due to a network or other infrastructure issue.
    Please check the Maze Runner and device logs to confirm.)
    MESSAGE
  end

  if precise
    Maze.check.equal(request_count, list.size_remaining, "#{list.size_remaining} #{list_name} received")
  else
    Maze.check.operator(request_count, :<=, list.size_remaining, "#{list.size_remaining} #{list_name} received")
    Maze.check.operator(maximum, :>=, list.size_remaining, "#{list.size_remaining} #{list_name} received") unless maximum.nil?
  end
end

#
# Request assertions
#
# Shortcut to waiting to receive a single request of the given type
#
# @step_input request_type [String] The type of request (error, session, build, etc)
Then('I wait to receive a(n) {request_type}') do |request_type|
  step "I wait to receive 1 #{request_type}"
end

# Continually checks to see if the required amount of requests have been received,
# timing out according to @see Maze.config.receive_requests_wait.
# If all expected requests are received and have the Bugsnag-Sent-At header, they
# will be sorted by the header.
#
# @step_input request_type [String] The type of request (error, session, build, etc)
# @step_input request_count [Integer] The amount of requests expected
Then('I wait to receive {int} {request_type}') do |request_count, request_type|
  list = Maze::Server.list_for(request_type)
  assert_received_requests request_count, list, request_type
  list.sort_by_sent_at! request_count
end

# Continually checks to see if at least the number requests given has been received,
# timing out according to @see Maze.config.receive_requests_wait.
#
# This step can tolerate receiving more than the expected number of requests.
#
# @step_input request_type [String] The type of request (error, session, build, etc)
# @step_input request_count [Integer] The amount of requests expected
Then('I wait to receive at least {int} {request_type}') do |request_count, request_type|
  list = Maze::Server.list_for(request_type)
  assert_received_requests request_count, list, request_type, false
end

# Sorts the remaining requests in a list by the field path given.
#
# @step_input request_type [String] The type of request (error, session, build, etc)
# @step_input field_path [String] The field to sort by
Then('I sort the {request_type} by the payload field {string}') do |request_type, field_path|
  list = Maze::Server.list_for(request_type)
  list.sort_by! field_path
end

# Verify that at least a certain amount of requests have been received
# This step is only intended for use in stress tests
#
# @step_input min_received [Integer] The minimum amount of requests required to pass
# @step_input request_type [String] The type of request (error, session, build, etc)
Then('I have received at least {int} {request_type}') do |min_received, request_type|
  list = Maze::Server.list_for(request_type)
  Maze.check.operator(list.size_remaining, :>=, min_received, "Actually received #{list.size_remaining} #{request_type} requests")
end

# Verify that an amount of requests within a range have been received
#
# @step_input min_received [Integer] The minimum amount of requests required to pass
# @step_input max_received [Integer] The maximum amount of requests before failure
# @step_input request_type [String] The type of request (error, session, build, etc)
Then('I wait to receive between {int} and {int} {request_type}') do |min_received, max_received, request_type|
  list = Maze::Server.list_for(request_type)
  assert_received_requests min_received, list, request_type, false, max_received
end

# Assert that the test Server hasn't received any requests - of a specific, or any, type.
#
# @step_input request_type [String] The type of request ('error', 'session', 'trace', sampling request', etc)
Then('I should receive no {request_type}') do |request_type|
  sleep Maze.config.receive_no_requests_wait
  list = Maze::Server.list_for(request_type)
  Maze.check.equal(0, list.size_remaining, "#{list.size_remaining} #{request_type} received")
end

# Moves to the next request
#
# @step_input request_type [String] The type of request (error, session, build, etc)
Then('I discard the oldest {request_type}') do |request_type|
  raise "No #{request_type} to discard" if Maze::Server.list_for(request_type).current.nil?

  Maze::Server.list_for(request_type).next
end

# Moves to the end of the request list
#
# @step_input request_type [String] The type of request (error, session, build, etc)
Then('I discard all {request_type}') do |request_type|
  raise "No #{request_type} to discard" if Maze::Server.list_for(request_type).current.nil?

  Maze::Server.list_for(request_type).end
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
      Maze.check.equal(1, events.length, 'Expected exactly one event per request')
      match_count += 1 if Maze::Assertions::RequestSetAssertions.request_matches_row(events[0], row)
    end
  end
  Maze.check.equal(requests.size, match_count, 'Unexpected number of requests matched the received payloads')
end

# Verifies that a request was sent via a given method.
# Currently only supported with the reflective servlet.
#
# @step_input request_type [String] The type of request (error, session, build, etc)
# @step_input method [String] The request method expected (GET, POST, etc)
Then('the {request_type} request method equals {string}') do |request_type, method|
  list = Maze::Server.list_for(request_type)
  payload = list.current
  if payload[:method].nil?
    raise Test::Unit::AssertionFailedError.new("#{request_type} request had no receipt method listed")
  end
  Maze.check.equal(method, payload[:method], "Expected #{request_type} request method to be #{method}")
end
