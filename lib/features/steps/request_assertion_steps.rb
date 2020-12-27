# frozen_string_literal: true

require 'test/unit'
require 'minitest'
require 'open-uri'
require 'json'
require 'cgi'
require_relative '../../wait'

include Test::Unit::Assertions

# @!group Request assertion steps

def check_for_requests(request_count, list, list_name)
  timeout = MazeRunner.config.receive_requests_wait
  wait = Maze::Wait.new(timeout: timeout)

  received = wait.until { list.size >= request_count }

  unless received
    raise <<-MESSAGE
    Expected #{request_count} #{list_name} but received #{list.size} within the #{timeout}s timeout.
    This could indicate that:
    - Bugsnag crashed with a fatal error.
    - Bugsnag did not make the requests that it should have done.
    - The requests were made, but not deemed to be valid (e.g. missing integrity header).
    Please check the Maze Runner and device logs to confirm.)
    MESSAGE
  end

  assert_equal(request_count, list.size, "#{list.size} #{list_name} received")
end


# Assert that the test Server hasn't received any requests at all.
Then('I should receive no requests') do
  sleep MazeRunner.config.receive_no_requests_wait
  assert_equal(0, Server.errors.size, "#{Server.errors.size} errors received")
  assert_equal(0, Server.sessions.size, "#{Server.sessions.size} sessions received")
end

#
# Error request assertions
#
Then('I wait to receive an error') do
  step 'I wait to receive 1 error'
end

# Continually checks to see if the required amount of errors have been received.
# Times out according to @see MazeRunner.config.receive_requests_wait.
#
# @step_input request_count [Integer] The amount of requests expected
Then('I wait to receive {int} error(s)') do |request_count|
  check_for_requests request_count, Server.errors, 'errors'
end

# Assert that the test Server hasn't received any errors.
Then('I should receive no errors') do
  sleep MazeRunner.config.receive_no_requests_wait
  assert_equal(0, Server.errors.size, "#{Server.errors.size} errors received")
end

Then('the received errors match:') do |table|
  # Checks that each request matches one of the event fields
  requests = Server.errors.remaining
  match_count = 0

  # iterate through each row in the table. exactly 1 request should match each row.
  table.hashes.each do |row|
    requests.each do |request|
      if !request.key? :body or !request[:body].key? "events" then
        # No body.events in this request - skip
        return
      end
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

# Shortcut to waiting to receive a single request

# Shortcut to waiting to receive a single session
Then('I wait to receive a session') do
  step 'I wait to receive 1 session'
end

# Moves to the next error
Then('I discard the oldest error') do
  raise 'No error to discard' if Server.errors.current.nil?

  Server.errors.next
end

# Continually checks to see if the required amount of sessions have been received.
# Times out according to @see MazeRunner.config.receive_requests_wait.
#
# @step_input request_count [Integer] The amount of requests expected
Then('I wait to receive {int} session(s)') do |request_count|
  check_for_requests request_count, Server.sessions, 'sessions'
end

# Assert that the test Server hasn't received any sessions.
Then('I should receive no sessions') do
  sleep MazeRunner.config.receive_no_requests_wait
  assert_equal(0, Server.sessions.size, "#{Server.sessions.size} sessions received")
end

# Moves to the next sessions
Then('I discard the oldest session') do
  raise 'No session to discard' if Server.sessions.current.nil?

  Server.sessions.next
end


#
# TODO There's a lot of overlap between error and session header assertions and only implemented this
# way for ease when separating from a single request endpoint.
#

#
# Errors
#

# Tests that an error header is not null
#
# @step_input header_name [String] The header to test
Then('the error {string} header is not null') do |header_name|
  assert_not_nil(Server.errors.current[:request][header_name],
                 "The error '#{header_name}' header should not be null")
end

# Tests that an error header equals a string
#
# @step_input header_name [String] The header to test
# @step_input header_value [String] The string it should match
Then('the error {string} header equals {string}') do |header_name, header_value|
  assert_not_nil(Server.errors.current[:request][header_name],
                 "The error '#{header_name}' header wasn't present in the request")
  assert_equal(header_value, Server.errors.current[:request][header_name])
end

# Tests that an error header matches a regex
#
# @step_input header_name [String] The header to test
# @step_input regex_string [String] The regex to match with
Then('the error {string} header matches the regex {string}') do |header_name, regex_string|
  regex = Regexp.new(regex_string)
  value = Server.errors.current[:request][header_name]
  assert_match(regex, value)
end

# Tests that an error header matches one of a list of strings
#
# @step_input header_name [String] The header to test
# @step_input header_values [DataTable] A parsed data table
Then('the error {string} header equals one of:') do |header_name, header_values|
  assert_includes(header_values.raw.flatten, Server.errors.current[:request][header_name])
end

# Tests that am error header is a timestamp.
#
# @step_input header_name [String] The header to test
Then('the error {string} header is a timestamp') do |header_name|
  header = Server.errors.current[:request][header_name]
  assert_match(TIMESTAMP_REGEX, header)
end

#
# Sessions
#

# Tests that a session header is not null
#
# @step_input header_name [String] The header to test
Then('the session {string} header is not null') do |header_name|
  assert_not_nil(Server.sessions.current[:request][header_name],
                 "The session '#{header_name}' header should not be null")
end

# Tests that a session header equals a string
#
# @step_input header_name [String] The header to test
# @step_input header_value [String] The string it should match
Then('the session {string} header equals {string}') do |header_name, header_value|
  assert_not_nil(Server.sessions.current[:request][header_name],
                 "The session '#{header_name}' header wasn't present in the request")
  assert_equal(header_value, Server.sessions.current[:request][header_name])
end

# Tests that a session header matches a regex
#
# @step_input header_name [String] The header to test
# @step_input regex_string [String] The regex to match with
Then('the session {string} header matches the regex {string}') do |header_name, regex_string|
  regex = Regexp.new(regex_string)
  value = Server.sessions.current[:request][header_name]
  assert_match(regex, value)
end

# Tests that a session header matches one of a list of strings
#
# @step_input header_name [String] The header to test
# @step_input header_values [DataTable] A parsed data table
Then('the session {string} header equals one of:') do |header_name, header_values|
  assert_includes(header_values.raw.flatten, Server.sessions.current[:request][header_name])
end

# Tests that a session header is a timestamp.
#
# @step_input header_name [String] The header to test
Then('the session {string} header is a timestamp') do |header_name|
  header = Server.sessions.current[:request][header_name]
  assert_match(TIMESTAMP_REGEX, header)
end

#
# TODO Split this section into query_parameter_assertion_steps
#

# Tests that a query parameter matches a string.
#
# @step_input parameter_name [String] The parameter to test
# @step_input parameter_value [String] The expected value
Then('the error {string} query parameter equals {string}') do |parameter_name, parameter_value|
  assert_equal(parameter_value, parse_querystring(Server.errors.current)[parameter_name][0])
end

# Tests that a query parameter is present and not null.
#
# @step_input parameter_name [String] The parameter to test
Then('the error {string} query parameter is not null') do |parameter_name|
  assert_not_nil(parse_querystring(Server.errors.current)[parameter_name][0],
                 "The '#{parameter_name}' query parameter should not be null")
end

# Tests that a query parameter is a timestamp.
#
# @step_input parameter_name [String] The parameter to test
Then('the error {string} query parameter is a timestamp') do |parameter_name|
  param = parse_querystring(Server.errors.current)[parameter_name][0]
  assert_match(TIMESTAMP_REGEX, param)
end

# Tests the payload body does not match a JSON fixture.
#
# @step_input fixture_path [String] Path to a JSON fixture
Then('the payload body does not match the JSON fixture in {string}') do |fixture_path|
  payload_value = Server.errors.current[:body]
  expected_value = JSON.parse(open(fixture_path, &:read))
  result = value_compare(expected_value, payload_value)
  assert_false(result.equal?, "Payload:\n#{payload_value}\nExpected:#{expected_value}")
end

# Test the payload body matches a JSON fixture.
#
# @step_input fixture_path [String] Path to a JSON fixture
Then('the payload body matches the JSON fixture in {string}') do |fixture_path|
  payload_value = Server.errors.current[:body]
  expected_value = JSON.parse(open(fixture_path, &:read))
  result = value_compare(expected_value, payload_value)
  assert_true(result.equal?,
              "The payload field '#{result.keypath}' does not match the fixture:\n #{result.reasons.join('\n')}")
end

# Test that a payload element matches a JSON fixture.
#
# @step_input field_path [String] Path to the tested element
# @step_input fixture_path [String] Path to a JSON fixture
Then('the payload field {string} matches the JSON fixture in {string}') do |field_path, fixture_path|
  payload_value = read_key_path(Server.errors.current[:body], field_path)
  expected_value = JSON.parse(open(fixture_path, &:read))
  result = value_compare(expected_value, payload_value)
  assert_true(result.equal?,
              "The payload field '#{result.keypath}' does not match the fixture:\n #{result.reasons.join('\n')}")
end

# Tests that a payload element is true.
#
# @step_input field_path [String] Path to the tested element
Then('the payload field {string} is true') do |field_path|
  assert_equal(true, read_key_path(Server.errors.current[:body], field_path))
end

# Tests that a payload element is false.
#
# @step_input field_path [String] Path to the tested element
Then('the payload field {string} is false') do |field_path|
  assert_equal(false, read_key_path(Server.errors.current[:body], field_path))
end

# Tests that a payload element is null.
#
# @step_input field_path [String] Path to the tested element
Then('the payload field {string} is null') do |field_path|
  value = read_key_path(Server.errors.current[:body], field_path)
  assert_nil(value, "The field '#{field_path}' should be null but is #{value}")
end

# Tests that a payload element is not null.
#
# @step_input field_path [String] Path to the tested element
Then('the payload field {string} is not null') do |field_path|
  assert_not_nil(read_key_path(Server.errors.current[:body], field_path),
                 "The field '#{field_path}' should not be null")
end

# Tests that a payload element equals an integer.
#
# @step_input field_path [String] Path to the tested element
# @step_input int_value [Integer] The value to test against
Then('the payload field {string} equals {int}') do |field_path, int_value|
  assert_equal(int_value, read_key_path(Server.errors.current[:body], field_path))
end

# Tests the payload field value against an environment variable.
#
# @step_input field_path [String] The payload element to test
# @step_input env_var [String] The environment variable to test against
Then('the payload field {string} equals the environment variable {string}') do |field_path, env_var|
  environment_value = ENV[env_var]
  assert_false(environment_value.nil?, "The environment variable #{env_var} must not be nil")
  value = read_key_path(Server.errors.current[:body], field_path)

  assert_equal(environment_value, value)
end

# Tests a payload field contains a number larger than a value.
#
# @step_input field_path [String] The payload element to test
# @step_input int_value [Integer] The value to compare against
Then('the payload field {string} is greater than {int}') do |field_path, int_value|
  value = read_key_path(Server.errors.current[:body], field_path)
  assert_kind_of Integer, value
  assert(value > int_value, "The payload field '#{field_path}' is not greater than '#{int_value}'")
end

# Tests a payload field contains a number smaller than a value.
#
# @step_input field_path [String] The payload element to test
# @step_input int_value [Integer] The value to compare against
Then('the payload field {string} is less than {int}') do |field_path, int_value|
  value = read_key_path(Server.errors.current[:body], field_path)
  assert_kind_of Integer, value
  assert(value < int_value, "The payload field '#{field_path}' is not less than '#{int_value}'")
end

# Tests a payload field equals a string.
#
# @step_input field_path [String] The payload element to test
# @step_input string_value [String] The string to test against
Then('the payload field {string} equals {string}') do |field_path, string_value|
  assert_equal(string_value, read_key_path(Server.errors.current[:body], field_path))
end

# Tests a payload field starts with a string.
#
# @step_input field_path [String] The payload element to test
# @step_input string_value [String] The string to test against
Then('the payload field {string} starts with {string}') do |field_path, string_value|
  value = read_key_path(Server.errors.current[:body], field_path)
  assert_kind_of String, value
  assert(value.start_with?(string_value),
         "Field '#{field_path}' value ('#{value}') does not start with '#{string_value}'")
end

# Tests a payload field ends with a string.
#
# @step_input field_path [String] The payload element to test
# @step_input string_value [String] The string to test against
Then('the payload field {string} ends with {string}') do |field_path, string_value|
  value = read_key_path(Server.errors.current[:body], field_path)
  assert_kind_of String, value
  assert(value.end_with?(string_value),
         "Field '#{field_path}' does not end with '#{string_value}'")
end

# Tests a payload field is an array with a specific element count.
#
# @step_input field [String] The payload element to test
# @step_input count [Integer] The value expected
Then('the payload field {string} is an array with {int} elements') do |field, count|
  value = read_key_path(Server.errors.current[:body], field)
  assert_kind_of Array, value
  assert_equal(count, value.length)
end

# Tests a payload field is an array with at least one element.
#
# @step_input field [String] The payload element to test
Then('the payload field {string} is a non-empty array') do |field|
  value = read_key_path(Server.errors.current[:body], field)
  assert_kind_of Array, value
  assert(value.length > 0,
         "the field '#{field}' must be a non-empty array")
end

# Tests a payload field matches a regex.
#
# @step_input field [String] The payload element to test
# @step_input regex [String] The regex to test against
Then('the payload field {string} matches the regex {string}') do |field, regex_string|
  regex = Regexp.new(regex_string)
  value = read_key_path(Server.errors.current[:body], field)
  assert_match(regex, value)
end

# Tests a payload field is a numeric timestamp.
#
# @step_input field [String] The payload element to test
Then('the payload field {string} is a parsable timestamp in seconds') do |field|
  value = read_key_path(Server.errors.current[:body], field)
  begin
    int = value.to_i
    parsed_time = Time.at(int)
  rescue StandardError
    parsed_time = nil
  end
  assert_not_nil(parsed_time)
end

# Tests that every element in an array contains a specified key-value pair.
#
# @step_input key_path [String] The path to the tested array
# @step_input element_key_path [String] The key for the expected element inside the array
Then('each element in payload field {string} has {string}') do |key_path, element_key_path|
  value = read_key_path(Server.errors.current[:body], key_path)
  assert_kind_of Array, value
  value.each do |element|
    assert_not_nil(read_key_path(element, element_key_path),
                   "Each element in '#{key_path}' must have '#{element_key_path}'")
  end
end
