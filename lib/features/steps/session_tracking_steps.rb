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

## SESSION FIELD ASSERTIONS
Then(/^the session "(.+)" is (true|false|null|not null)$/) do |field, literal|
  step "the payload field \"sessions.0.#{field}\" is #{literal}"
end
Then("the session {string} equals {string}") do |field, string_value|
  step "the payload field \"sessions.0.#{field}\" equals \"#{string_value}\""
end
Then("the session {string} is a timestamp") do |field|
  step "the payload field \"sessions.0.#{field}\" matches the regex \"#{TIMESTAMP_REGEX}\""
end

## SESSION COUNT ASSERTIONS
Then(/^the sessionCount "(.+)" is (true|false|null|not null)$/) do |field, literal|
  step "the payload field \"sessionCounts.0.#{field}\" is #{literal}"
end
Then("the sessionCount {string} equals {string}") do |field, string_value|
  step "the payload field \"sessionCounts.0.#{field}\" equals \"#{string_value}\""
end
Then("the sessionCount {string} equals {int}") do |field, int_value|
  step "the payload field \"sessionCounts.0.#{field}\" equals #{int_value}"
end
Then("the sessionCount {string} is a timestamp") do |field|
  step "the payload field \"sessionCounts.0.#{field}\" matches the regex \"#{TIMESTAMP_REGEX}\""
end

## SESSION ARRAY ASSERTIONS
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

# Tests a payload has the same session id as the following payload
Then("the payload has the same session id as the following event payload") do
  # Check if the first payload is an event or session payload
  session_payload = read_key_path(Server.current_request[:body], 'sessions').nil?
  if session_payload
    step "the payload field \"sessions.0.id\" in the current request matches the payload field \"events.0.session.id\" in the next request"
  else
    step "the payload field \"events.0.session.id\" in the current request matches the payload field \"events.0.session.id\" in the next request"
  end
end

# Tests a payload doesn't have the same session id as the following payload
Then("the payload does not have the same session id as the following event payload") do
  # Check if the first payload is an event or session payload
  session_payload = read_key_path(Server.current_request[:body], 'sessions').nil?
  if session_payload
    step "the payload field \"sessions.0.id\" in the current request does not match the payload field \"events.0.session.id\" in the next request"
  else
    step "the payload field \"events.0.session.id\" in the current request does not match the payload field \"events.0.session.id\" in the next request"
  end
end