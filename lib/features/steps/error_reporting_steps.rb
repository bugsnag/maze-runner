# frozen_string_literal: true

# @!group Error reporting steps

# Verifies that generic elements of an error payload are present.
# APIKey fields and headers are tested against the '$api_key' global variable.
#
# @step_input version [String] The payload version expected
# @step_input name [String] The expected name of the notifier
Then('the error is valid for the error reporting API version {string} for the {string} notifier') do |version, name|
  step "the error is valid for the error reporting API version \"#{version}\"" \
       " for the \"#{name}\" notifier with the apiKey \"#{$api_key}\""
end

# Verifies that generic elements of an error payload are present.
#
# @step_input version [String] The payload version expected
# @step_input name [String] The expected name of the notifier
# @step_input api_key [String] The API key expected
Then('the error is valid for the error reporting API version {string}' \
     ' for the {string} notifier with the apiKey {string}') do |payload_version, notifier_name, api_key|
  steps %(
    Then the error "Bugsnag-Api-Key" header equals "#{api_key}"
    And the error payload field "apiKey" equals "#{api_key}"
    And the error "Bugsnag-Payload-Version" header equals "#{payload_version}"
    And the error payload contains the payloadVersion "#{payload_version}"
    And the error "Content-Type" header equals "application/json"
    And the error "Bugsnag-Sent-At" header is a timestamp
    And the error Bugsnag-Integrity header is valid

    And the error payload field "notifier.name" equals "#{notifier_name}"
    And the error payload field "notifier.url" is not null
    And the error payload field "notifier.version" is not null
    And the error payload field "events" is a non-empty array

    And each element in error payload field "events" has "severity"
    And each element in error payload field "events" has "severityReason.type"
    And each element in error payload field "events" has "unhandled"
    And each element in error payload field "events" has "exceptions"
  )
end


# Verifies that an event is correct for an unhandled error
# This checks various elements of the payload matching an unhandled error including:
#    The unhandled flag
#    Any attached session information
#    Severity
#
# @param event [Integer] The event to verify
Then('event {int} is unhandled') do |event|
  test_unhandled_state(event, true)
end

# Verifies that an event is correct for an unhandled error
# This checks various elements of the payload matching an unhandled error including:
#    The unhandled flag
#    Any attached session information
#    Severity
#
# @param event [Integer] The event to verify
# @param severity [String] An expected severity different to the default "error"
Then('event {int} is unhandled with the severity {string}') do |event, severity|
  test_unhandled_state(event, true, severity)
end

# Verifies that an event is correct for an handled error
# This checks various elements of the payload matching an unhandled error including:
#    The unhandled flag
#    Any attached session information
#    Severity
#
# @param event [Integer] The event to verify
Then('event {int} is handled') do |event|
  test_unhandled_state(event, false)
end

# Verifies that an event is correct for an handled error
# This checks various elements of the payload matching an unhandled error including:
#    The unhandled flag
#    Any attached session information
#    Severity
#
# @param event [Integer] The event to verify
# @param severity [String] An expected severity different to the default "error"
Then('event {int} is handled with the severity {string}') do |event, severity|
  test_unhandled_state(event, false, severity)
end

# Checks the payloadVersion is set correctly.
#   For Javascript this should be in the events.
#   For all other notifiers this should be a top-level key.
#
# @step_input payload_version [String] The payload version expected
Then('the error payload contains the payloadVersion {string}') do |payload_version|
  body_version = Maze::Helper.read_key_path(Maze::Server.errors.current[:body], 'payloadVersion')
  body_set = payload_version == body_version
  event_version = Maze::Helper.read_key_path(Maze::Server.errors.current[:body], 'events.0.payloadVersion')
  event_set = payload_version == event_version
  assert_true(
    body_set || event_set,
    "The payloadVersion was not the expected value of #{payload_version}. " \
    "#{body_version} found in body, #{event_version} found in event"
  )
end

# Tests whether a value in the first event entry matches a literal.
#
# @step_input field [String] The relative location of the value to test
# @step_input literal [Enum] The literal to test against, one of: true, false, null, not null
Then(/^the event "(.+)" is (true|false|null|not null)$/) do |field, literal|
  step "the error payload field \"events.0.#{field}\" is #{literal}"
end

# Tests whether a value in the first event entry matches a string.
#
# @step_input field [String] The relative location of the value to test
# @step_input string_value [String] The string to match against
Then('the event {string} equals {string}') do |field, string_value|
  step "the error payload field \"events.0.#{field}\" equals \"#{string_value}\""
end

# Tests whether a value in the first event entry equals an integer.
#
# @step_input field [String] The relative location of the value to test
# @step_input value [Integer] The integer to test against
Then('the event {string} equals {int}') do |field, value|
  step "the error payload field \"events.0.#{field}\" equals #{value}"
end

# Tests whether a value in the first event entry starts with a string.
#
# @step_input field [String] The relative location of the value to test
# @step_input string_value [String] The string to match against
Then('the event {string} starts with {string}') do |field, string_value|
  step "the error payload field \"events.0.#{field}\" starts with \"#{string_value}\""
end

# Tests whether a value in the first event entry ends with a string.
#
# @step_input field [String] The relative location of the value to test
# @step_input string_value [String] The string to match against
Then('the event {string} ends with {string}') do |field, string_value|
  step "the error payload field \"events.0.#{field}\" ends with \"#{string_value}\""
end

# Tests whether a value in the first event entry matches a regex.
#
# @step_input field [String] The relative location of the value to test
# @step_input pattern [String] The regex to match against
Then('the event {string} matches {string}') do |field, pattern|
  step "the error payload field \"events.0.#{field}\" matches the regex \"#{pattern}\""
end

# Tests whether a value in the first event entry is a timestamp.
#
# @step_input field [String] The relative location of the value to test
Then('the event {string} is a timestamp') do |field|
  step "the error payload field \"events.0.#{field}\" matches the regex \"#{TIMESTAMP_REGEX}\""
end

# Tests whether a value in the first event entry is a numeric and parsable timestamp.
#
# @step_input field [String] The relative location of the value to test
Then('the event {string} is a parsable timestamp in seconds') do |field|
  step "the error payload field \"events.0.#{field}\" is a parsable timestamp in seconds"
end

# Tests the Event field value against an environment variable.
#
# @step_input field [String] The payload element to check
# @step_input env_var [String] The environment variable to test against
Then('the event {string} equals the environment variable {string}') do |field, env_var|
  step "the error payload field \"events.0.#{field}\" equals the environment variable \"#{env_var}\""
end

# Tests whether a value in the first event entry matches a JSON fixture.
#
# @step_input field [String] The relative location of the value to test
# @step_input fixture_path [String] The fixture to match against
Then('the event {string} matches the JSON fixture in {string}') do |field, fixture_path|
  step "the error payload field \"events.0.#{field}\" matches the JSON fixture in \"#{fixture_path}\""
end

Then('the event {string} string is empty') do |keypath|
  value = Maze::Helper.read_key_path(Maze::Server.errors.current[:body], keypath)
  assert_block("The #{keypath} is not empty: '#{value}'") do
    value.nil? || value.empty?
  end
end

Then('the event {string} is greater than {int}') do |keypath, int|
  value = Maze::Helper.read_key_path(Maze::Server.errors.current[:body], "events.0.#{keypath}")
  assert_false(value.nil?, "The event #{keypath} is nil")
  assert_true(value > int)
end

# Tests whether a value in the first exception of the first event entry starts with a string.
#
# @step_input field [String] The relative location of the value to test
# @step_input string_value [String] The string to match against
Then('the exception {string} starts with {string}') do |field, string_value|
  step "the error payload field \"events.0.exceptions.0.#{field}\" starts with \"#{string_value}\""
end

# Tests whether a value in the first exception of the first event entry ends with a string.
#
# @step_input field [String] The relative location of the value to test
# @step_input string_value [String] The string to match against
Then('the exception {string} ends with {string}') do |field, string_value|
  step "the error payload field \"events.0.exceptions.0.#{field}\" ends with \"#{string_value}\""
end

# Tests whether a value in the first exception of the first event entry equals a string.
#
# @step_input field [String] The relative location of the value to test
# @step_input string_value [String] The string to match against
Then('the exception {string} equals {string}') do |field, string_value|
  step "the error payload field \"events.0.exceptions.0.#{field}\" equals \"#{string_value}\""
end

# Tests whether a value in the first exception of the first event entry matches a regex.
#
# @step_input field [String] The relative location of the value to test
# @step_input pattern [String] The regex to match against
Then('the exception {string} matches {string}') do |field, pattern|
  step "the error payload field \"events.0.exceptions.0.#{field}\" matches the regex \"#{pattern}\""
end

# Tests whether a element of a stack frame in the first exception of the first event equals an integer.
#
# @step_input key [String] The element of the stack frame to test
# @step_input num [Integer] The stack frame where the element is present
# @step_input value [Integer] The value to test against
Then('the {string} of stack frame {int} equals {int}') do |key, num, value|
  field = "events.0.exceptions.0.stacktrace.#{num}.#{key}"
  step "the error payload field \"#{field}\" equals #{value}"
end

# Tests whether an element of a stack frame in the first exception of the first event matches a regex pattern.
#
# @step_input key [String] The element of the stack frame to test
# @step_input num [Integer] The stack frame where the element is present
# @step_input pattern [String] The regex to match against
Then('the {string} of stack frame {int} matches {string}') do |key, num, pattern|
  field = "events.0.exceptions.0.stacktrace.#{num}.#{key}"
  step "the error payload field \"#{field}\" matches the regex \"#{pattern}\""
end

# Tests whether an element of a stack frame in the first exception of the first event equals a string.
#
# @step_input key [String] The element of the stack frame to test
# @step_input num [Integer] The stack frame where the element is present
# @step_input value [String] The value to test against
Then('the {string} of stack frame {int} equals {string}') do |key, num, value|
  field = "events.0.exceptions.0.stacktrace.#{num}.#{key}"
  step "the error payload field \"#{field}\" equals \"#{value}\""
end

# Tests whether an element of a stack frame in the first exception of the first event starts with a string.
#
# @step_input key [String] The element of the stack frame to test
# @step_input num [Integer] The stack frame where the element is present
# @step_input value [String] The value to test against
Then('the {string} of stack frame {int} starts with {string}') do |key, num, value|
  field = "events.0.exceptions.0.stacktrace.#{num}.#{key}"
  step "the error payload field \"#{field}\" starts with \"#{value}\""
end

# Tests whether an element of a stack frame in the first exception of the first event ends with a string.
#
# @step_input key [String] The element of the stack frame to test
# @step_input num [Integer] The stack frame where the element is present
# @step_input value [String] The value to test against
Then('the {string} of stack frame {int} ends with {string}') do |key, num, value|
  field = "events.0.exceptions.0.stacktrace.#{num}.#{key}"
  step "the error payload field \"#{field}\" ends with \"#{value}\""
end

# Tests whether an element of a stack frame in the first exception of the first event matches a literal.
#
# @step_input key [String] The element of the stack frame to test
# @step_input num [Integer] The stack frame where the element is present
# @step_input literal [Enum] The literal to test against, one of: true, false, null, not null
Then(/^the "(.*)" of stack frame (\d*) is (true|false|null|not null)$/) do |key, num, literal|
  field = "events.0.exceptions.0.stacktrace.#{num}.#{key}"
  step "the error payload field \"#{field}\" is #{literal}"
end

# Tests whether a thread from the first event, identified by name, is the error reporting thread.
#
# @step_input thread_name [String] The name of the thread to test
Then('the thread with name {string} contains the error reporting flag') do |thread_name|
  validate_error_reporting_thread('name', thread_name)
end

# Tests whether a thread from the first event, identified by an id, is the error reporting thread.
#
# @step_input thread_id [String] The id of the thread to test
Then('the thread with id {string} contains the error reporting flag') do |thread_id|
  validate_error_reporting_thread('id', thread_id)
end

# Tests that a thread from the first event, identified by a particular key-value pair, is the error reporting thread.
#
# @param payload_key [String] The thread identifier key
# @param payload_value [Any] The thread identifier value
def validate_error_reporting_thread(payload_key, payload_value)
  threads = Maze::Server.errors.current[:body]['events'].first['threads']
  assert_kind_of Array, threads
  count = 0

  threads.each do |thread|
    count += 1 if thread[payload_key].to_s == payload_value && thread['errorReportingThread'] == true
  end
  assert_equal(1, count)
end

# Tests whether an event has the correct attributes we'd expect for un/handled events
#
# @param event [Integer] The index of the event
# @param unhandled [Boolean] Whether the event is unhandled or handled
# @param severity [String] Optional. An overwritten severity to look for
def test_unhandled_state(event, unhandled, severity = nil)
  expected_unhandled_state = unhandled ? 'true' : 'false'
  expected_severity = if severity
                        severity
                      elsif unhandled
                        'error'
                      else
                        'warning'
                      end
  steps %(
    Then the error payload field "events.#{event}.unhandled" is #{expected_unhandled_state}
    And the error payload field "events.#{event}.severity" equals "#{expected_severity}"
  )

  return if Maze::Helper.read_key_path(Maze::Server.errors.current[:body], "events.#{event}.session").nil?

  session_field = unhandled ? 'unhandled' : 'handled'
  steps %(
    And the error payload field "events.#{event}.session.events.#{session_field}" is greater than 0
  )
end
