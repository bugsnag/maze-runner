# @!group Session tracking steps

# Verifies that generic elements of a session payload are present.
# APIKey fields and headers are tested against the '$api_key' global variable.
#
# @step_input payload_version [String] The payload version expected
# @step_input notifier_name [String] The expected name of the notifier
Then("the session is valid for the session reporting API version {string} for the {string} notifier") do |payload_version, notifier_name|
  steps %Q{
    Then the session "bugsnag-api-key" header equals "#{$api_key}"
    And the session "bugsnag-payload-version" header equals "#{payload_version}"
    And the session "Content-Type" header equals "application/json"
    And the session "Bugsnag-Sent-At" header is a timestamp

    And the session payload field "notifier.name" equals "#{notifier_name}"
    And the session payload field "notifier.url" is not null
    And the session payload field "notifier.version" is not null

    And the session payload field "app" is not null
    And the session payload field "device" is not null
  }
end


# Verifies that generic elements of a session payload are present for the React Native notifier
# APIKey fields and headers are tested against the '$api_key' global variable.
#
# @step_input payload_version [String] The payload version expected
# @step_input notifier_name [String] The expected name of the notifier
# TODO: I'm reluctant to risk changing the previous step implementation right now, but we should consider
#   refactoring the two at some point to avoid duplication.
Then('the session is valid for the session reporting API version {string} for the React Native notifier') do |payload_version|
  steps %Q{
    Then the session "bugsnag-api-key" header equals "#{$api_key}"
    And the session "bugsnag-payload-version" header equals "#{payload_version}"
    And the session "Content-Type" header equals "application/json"
    And the session "Bugsnag-Sent-At" header is a timestamp

    And the session payload field "notifier.name" matches the regex "(Android|iOS) Bugsnag Notifier"
    And the session payload field "notifier.url" is not null
    And the session payload field "notifier.version" is not null

    And the session payload field "app" is not null
    And the session payload field "device" is not null
  }
end

# Tests whether a value in the first session entry matches a literal.
#
# @step_input field [String] The relative location of the value to test
# @step_input literal [Enum] The literal to test against, one of: true, false, null, not null
Then(/^the session "(.+)" is (true|false|null|not null)$/) do |field, literal|
  step "the session payload field \"sessions.0.#{field}\" is #{literal}"
end

# Tests whether a value in the first session entry matches a string.
#
# @step_input field [String] The relative location of the value to test
# @step_input string_value [String] The string to match against
Then("the session {string} equals {string}") do |field, string_value|
  step "the session payload field \"sessions.0.#{field}\" equals \"#{string_value}\""
end

# Tests whether a value in the first session entry is a timestamp.
#
# @step_input field [String] The relative location of the value to test
Then("the session {string} is a timestamp") do |field|
  step "the session payload field \"sessions.0.#{field}\" matches the regex \"#{TIMESTAMP_REGEX}\""
end

# Tests whether a value in the first sessionCount entry matches a literal.
#
# @step_input field [String] The relative location of the value to test
# @step_input literal [Enum] The literal to test against, one of: true, false, null, not null
Then(/^the sessionCount "(.+)" is (true|false|null|not null)$/) do |field, literal|
  step "the session payload field \"sessionCounts.0.#{field}\" is #{literal}"
end

# Tests whether a value in the first sessionCount entry matches a string.
#
# @step_input field [String] The relative location of the value to test
# @step_input string_value [String] The string to match against
Then("the sessionCount {string} equals {string}") do |field, string_value|
  step "the session payload field \"sessionCounts.0.#{field}\" equals \"#{string_value}\""
end

# Tests whether a value in the first sessionCount entry equals an integer.
#
# @step_input field [String] The relative location of the value to test
# @step_input int_value [Integer] The integer to test against
Then("the sessionCount {string} equals {int}") do |field, int_value|
  step "the session payload field \"sessionCounts.0.#{field}\" equals #{int_value}"
end

# Tests whether a value in the first sessionCount entry is a timestamp.
#
# @step_input field [String] The relative location of the value to test
Then("the sessionCount {string} is a timestamp") do |field|
  step "the session payload field \"sessionCounts.0.#{field}\" matches the regex \"#{TIMESTAMP_REGEX}\""
end

# Tests that a payload has an appropriately structured session array
Then("the session payload has a valid sessions array") do
  if sessions = Server.sessions.current[:body]["sessions"]
    steps %Q{
      Then the session "id" is not null
      And the session "startedAt" is a timestamp
    }
  else
    steps %Q{
      Then the sessionCount "sessionsStarted" is not null
      And the sessionCount "startedAt" is a timestamp
    }
  end
end

# Tests that a session payload element is true.
#
# @step_input field_path [String] Path to the tested element
Then('the session payload field {string} is true') do |field_path|
  assert_equal(true, read_key_path(Server.sessions.current[:body], field_path))
end

# Tests that a session payload element is false.
#
# @step_input field_path [String] Path to the tested element
Then('the session payload field {string} is false') do |field_path|
  assert_equal(false, read_key_path(Server.sessions.current[:body], field_path))
end

# Tests that a payload element is null.
#
# @step_input field_path [String] Path to the tested element
Then('the session payload field {string} is null') do |field_path|
  value = read_key_path(Server.sessions.current[:body], field_path)
  assert_nil(value, "The field '#{field_path}' should be null but is #{value}")
end

# Tests that a session payload element is not null.
#
# @step_input field_path [String] Path to the tested element
Then('the session payload field {string} is not null') do |field_path|
  assert_not_nil(read_key_path(Server.sessions.current[:body], field_path),
                 "The field '#{field_path}' should not be null")
end

# Tests that a session payload element equals an integer.
#
# @step_input field_path [String] Path to the tested element
# @step_input int_value [Integer] The value to test against
Then('the session payload field {string} equals {int}') do |field_path, int_value|
  assert_equal(int_value, read_key_path(Server.sessions.current[:body], field_path))
end

# Tests a session payload field equals a string.
#
# @step_input field_path [String] The payload element to test
# @step_input string_value [String] The string to test against
Then('the session payload field {string} equals {string}') do |field_path, string_value|
  assert_equal(string_value, read_key_path(Server.sessions.current[:body], field_path))
end

# Tests a session payload field matches a regex.
#
# @step_input field [String] The payload element to test
# @step_input regex [String] The regex to test against
Then('the session payload field {string} matches the regex {string}') do |field, regex_string|
  regex = Regexp.new(regex_string)
  value = read_key_path(Server.sessions.current[:body], field)
  assert_match(regex, value)
end

