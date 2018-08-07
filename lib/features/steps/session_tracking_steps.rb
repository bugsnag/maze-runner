Then("the request is a valid for the session tracking API") do
  steps %Q{
    Then the "Bugsnag-API-Key" header is not null
    And the "Content-Type" header equals "application/json"
    And the "Bugsnag-Payload-Version" header equals "1.0"
    And the "Bugsnag-Sent-At" header is a timestamp

    And the payload field "app" is not null
    And the payload field "device" is not null
    And the payload field "notifier.name" is not null
    And the payload field "notifier.url" is not null
    And the payload field "notifier.version" is not null
    And the payload has a valid sessions array
  }
end
Then("the session {string} is true") do |field|
  step "the payload field \"sessions.0.#{field}\" is true"
end
Then("the session {string} is false") do |field|
  step "the payload field \"sessions.0.#{field}\" is false"
end
Then(/^the session "(.+)" equals "(.+)"$/) do |field, string_value|
  step "the payload field \"sessions.0.#{field}\" equals \"#{string_value}\""
end
Then(/^the session "(.+)" is not null$/) do |field|
  step "the payload field \"sessions.0.#{field}\" is not null"
end
Then(/^the session "(.+)" is null$/) do |field|
  step "the payload field \"sessions.0.#{field}\" is null"
end
Then(/^the session "(.+)" is a timestamp$/) do |field|
  timestamp_regex = /^\d{4}\-\d{2}\-\d{2}T\d{2}:\d{2}:[\d\.]+Z?$/
  step "the payload field \"sessions.0.#{field}\" matches the regex \"#{timestamp_regex}\""
end
Then("the sessionCount {string} is true") do |field|
  step "the payload field \"sessionCounts.0.#{field}\" is true"
end
Then("the sessionCount {string} is false") do |field|
  step "the payload field \"sessionCounts.0.#{field}\" is false"
end
Then(/^the sessionCount "(.+)" equals "(.+)"$/) do |field, string_value|
  step "the payload field \"sessionCounts.0.#{field}\" equals \"#{string_value}\""
end
Then(/^the sessionCount "(.+)" equals (\d+)$/) do |field, int_value|
  step "the payload field \"sessionCounts.0.#{field}\" equals #{int_value}"
end
Then(/^the sessionCount "(.+)" is not null$/) do |field|
  step "the payload field \"sessionCounts.0.#{field}\" is not null"
end
Then(/^the sessionCount "(.+)" is null$/) do |field|
  step "the payload field \"sessionCounts.0.#{field}\" is null"
end
Then(/^the sessionCount "(.+)" is a timestamp$/) do |field|
  timestamp_regex = /^\d{4}\-\d{2}\-\d{2}T\d{2}:\d{2}:[\d\.]+Z?$/
  step "the payload field \"sessionCounts.0.#{field}\" matches the regex \"#{timestamp_regex}\""
end
