# @!group Session tracking steps

# Verifies that generic elements of a session payload are present.
# APIKey fields and headers are tested against the '$api_key' global variable.
#
# @step_input payload_version [String] The payload version expected
# @step_input notifier_name [String] The expected name of the notifier
Then("the request is valid for the session reporting API version {string} for the {string} notifier") do |payload_version, notifier_name|
  steps %Q{
    Then the "bugsnag-api-key" header equals "#{$api_key}"
    And the "bugsnag-payload-version" header equals "#{payload_version}"
    And the "Content-Type" header equals "application/json"
    And the "Bugsnag-Sent-At" header is a timestamp

    And the payload field "notifier.name" equals "#{notifier_name}"
    And the payload field "notifier.url" is not null
    And the payload field "notifier.version" is not null

    And the payload field "app" is not null
    And the payload field "device" is not null
  }
end


# Verifies that generic elements of a session payload are present for the React Native notifier
# APIKey fields and headers are tested against the '$api_key' global variable.
#
# @step_input payload_version [String] The payload version expected
# @step_input notifier_name [String] The expected name of the notifier
# TODO: I'm reluctant to risk changing the previous step implementation right now, but we should consider
#   refactoring the two at some point to avoid duplication.
Then('the request is valid for the session reporting API version {string} for the React Native notifier') do |payload_version|
  steps %Q{
    Then the "bugsnag-api-key" header equals "#{$api_key}"
    And the "bugsnag-payload-version" header equals "#{payload_version}"
    And the "Content-Type" header equals "application/json"
    And the "Bugsnag-Sent-At" header is a timestamp

    And the payload field "notifier.name" matches the regex "(Android|iOS) Bugsnag Notifier"
    And the payload field "notifier.url" is not null
    And the payload field "notifier.version" is not null

    And the payload field "app" is not null
    And the payload field "device" is not null
  }
end

# Tests whether a value in the first session entry matches a literal.
#
# @step_input field [String] The relative location of the value to test
# @step_input literal [Enum] The literal to test against, one of: true, false, null, not null
Then(/^the session "(.+)" is (true|false|null|not null)$/) do |field, literal|
  step "the payload field \"sessions.0.#{field}\" is #{literal}"
end

# Tests whether a value in the first session entry matches a string.
#
# @step_input field [String] The relative location of the value to test
# @step_input string_value [String] The string to match against
Then("the session {string} equals {string}") do |field, string_value|
  step "the payload field \"sessions.0.#{field}\" equals \"#{string_value}\""
end

# Tests whether a value in the first session entry is a timestamp.
#
# @step_input field [String] The relative location of the value to test
Then("the session {string} is a timestamp") do |field|
  step "the payload field \"sessions.0.#{field}\" matches the regex \"#{TIMESTAMP_REGEX}\""
end

# Tests whether a value in the first sessionCount entry matches a literal.
#
# @step_input field [String] The relative location of the value to test
# @step_input literal [Enum] The literal to test against, one of: true, false, null, not null
Then(/^the sessionCount "(.+)" is (true|false|null|not null)$/) do |field, literal|
  step "the payload field \"sessionCounts.0.#{field}\" is #{literal}"
end

# Tests whether a value in the first sessionCount entry matches a string.
#
# @step_input field [String] The relative location of the value to test
# @step_input string_value [String] The string to match against
Then("the sessionCount {string} equals {string}") do |field, string_value|
  step "the payload field \"sessionCounts.0.#{field}\" equals \"#{string_value}\""
end

# Tests whether a value in the first sessionCount entry equals an integer.
#
# @step_input field [String] The relative location of the value to test
# @step_input int_value [Integer] The integer to test against
Then("the sessionCount {string} equals {int}") do |field, int_value|
  step "the payload field \"sessionCounts.0.#{field}\" equals #{int_value}"
end

# Tests whether a value in the first sessionCount entry is a timestamp.
#
# @step_input field [String] The relative location of the value to test
Then("the sessionCount {string} is a timestamp") do |field|
  step "the payload field \"sessionCounts.0.#{field}\" matches the regex \"#{TIMESTAMP_REGEX}\""
end

# Tests that a payload has an appropriately structured session array
Then("the payload has a valid sessions array") do
  if sessions = Server.current_request[:body]["sessions"]
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
