# frozen_string_literal: true

require 'test/unit'
require 'open-uri'
require 'json'
require 'cgi'
require_relative '../../maze/wait'

# @!group Request assertion steps

def assert_received_requests(request_count, list, list_name, precise = true)
  timeout = Maze.config.receive_requests_wait
  wait = Maze::Wait.new(timeout: timeout)

  received = wait.until { list.size_remaining >= request_count }

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
  end

  verify_schema_matches(list, list_name)
end

def verify_schema_matches(list, list_name)
  request_schema_results = list.all.map { |request| request[:schema_errors] }
  passed = true
  request_schema_results.each.with_index(1) do |schema_errors, index|
    if schema_errors.size > 0
      passed = false
      $stdout.puts "\n"
      $stdout.puts "\e[31m--- #{list_name} #{index} failed validation with errors at the following locations:\e[0m"
      schema_errors.each do |error|
        $stdout.puts "\e[31m#{error["data_pointer"]} failed to match #{error["schema_pointer"]}\e[0m"
      end
      $stdout.puts "\n"
    end
  end

  unless passed
    raise Test::Unit::AssertionFailedError.new 'The received payloads did not match the endpoint schema.  A full list of the errors can be found above'
  end
end

#
# Error request assertions
#
# Shortcut to waiting to receive a single request of the given type
#
# @step_input request_type [String] The type of request (error, session, build, etc)
Then('I wait to receive a(n) {word}') do |request_type|
  step "I wait to receive 1 #{request_type}"
end

# Continually checks to see if the required amount of requests have been received,
# timing out according to @see Maze.config.receive_requests_wait.
# If all expected requests are received and have the Bugsnag-Sent-At header, they
# will be sorted by the header.
#
# @step_input request_type [String] The type of request (error, session, build, etc)
# @step_input request_count [Integer] The amount of requests expected
Then('I wait to receive {int} {word}') do |request_count, request_type|
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
Then('I wait to receive at least {int} {word}') do |request_count, request_type|
  list = Maze::Server.list_for(request_type)
  assert_received_requests request_count, list, request_type, false
end

# Sorts the remaining requests in a list by the field path given.
#
# @step_input request_type [String] The type of request (error, session, build, etc)
# @step_input field_path [String] The field to sort by
Then('I sort the {word} by the payload field {string}') do |request_type, field_path|
  list = Maze::Server.list_for(request_type)
  list.sort_by! field_path
end

# Verify that at least a certain amount of requests have been received
# This step is only intended for use in stress tests
#
# @step_input min_received [Integer] The minimum amount of requests required to pass
# @step_input request_type [String] The type of request (error, session, build, etc)
Then('I have received at least {int} {word}') do |min_received, request_type|
  list = Maze::Server.list_for(request_type)
  Maze.check.operator(list.size_remaining, :>=, min_received, "Actually received #{list.size} #{request_type} requests")
end

# Assert that the test Server hasn't received any requests - of a specific, or any, type.
#
# @step_input request_type [String] The type of request ('error', 'session', build, etc), or 'requests' to assert on all
#   request types.
Then('I should receive no {word}') do |request_type|
  sleep Maze.config.receive_no_requests_wait
  if request_type == 'requests'
    # Assert that the test Server hasn't received any requests at all.
    Maze.check.equal(0, Maze::Server.errors.size_remaining, "#{Maze::Server.errors.size_remaining} errors received")
    Maze.check.equal(0, Maze::Server.sessions.size_remaining, "#{Maze::Server.sessions.size_remaining} sessions received")
  else
    list = Maze::Server.list_for(request_type)
    Maze.check.equal(0, list.size_remaining, "#{list.size_remaining} #{request_type} received")
  end
end

# Moves to the next request
#
# @step_input request_type [String] The type of request (error, session, build, etc)
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
      Maze.check.equal(1, events.length, 'Expected exactly one event per request')
      match_count += 1 if Maze::Assertions::RequestSetAssertions.request_matches_row(events[0], row)
    end
  end
  Maze.check.equal(requests.size, match_count, 'Unexpected number of requests matched the received payloads')
end
