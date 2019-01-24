Then("the request is valid for the error reporting API version {string} for the {string} notifier") do |payload_version, notifier_name|
  steps %Q{
    Then the "Bugsnag-Api-Key" header equals "#{$api_key}"
    And the payload field "apiKey" equals "#{$api_key}"
    And the "Bugsnag-Payload-Version" header equals "#{payload_version}"
    And the payload field "events.0.payloadVersion" equals "#{payload_version}"
    And the "Content-Type" header equals "application/json"
    And the "Bugsnag-Sent-At" header is a timestamp

    And the payload field "notifier.name" equals "#{notifier_name}"
    And the payload field "notifier.url" is not null
    And the payload field "notifier.version" is not null
    And the payload field "events" is a non-empty array

    And each element in payload field "events" has "severity"
    And each element in payload field "events" has "severityReason.type"
    And each element in payload field "events" has "unhandled"
    And each element in payload field "events" has "exceptions"
  }
end

## EVENT FIELD ASSERTIONS
Then(/^the event "(.+)" is (true|false|null|not null)$/) do |field, literal|
  step "the payload field \"events.0.#{field}\" is #{literal}"
end
Then("the event {string} equals {string}") do |field, string_value|
  step "the payload field \"events.0.#{field}\" equals \"#{string_value}\""
end
Then("the event {string} equals {int}") do |field, value|
  step "the payload field \"events.0.#{field}\" equals #{value}"
end
Then("the event {string} starts with {string}") do |field, string_value|
  step "the payload field \"events.0.#{field}\" starts with \"#{string_value}\""
end
Then("the event {string} ends with {string}") do |field, string_value|
  step "the payload field \"events.0.#{field}\" ends with \"#{string_value}\""
end
Then("the event {string} matches {string}") do |field, pattern|
  step "the payload field \"events.0.#{field}\" matches the regex \"#{pattern}\""
end
Then("the event {string} is a timestamp") do |field|
  step "the payload field \"events.0.#{field}\" matches the regex \"#{TIMESTAMP_REGEX}\""
end
Then("the event {string} is a parsable timestamp in seconds") do |field|
  step "the payload field \"events.0.#{field}\" is a parsable timestamp in seconds"
end

## JSON FIXTURE ASSERTIONS
Then("the event {string} matches the JSON fixture in {string}") do |field, fixture_path|
  step "the payload field \"events.0.#{field}\" matches the JSON fixture in \"#{fixture_path}\""
end

## BREADCRUMB ASSERTIONS
Then("the event has a {string} breadcrumb named {string}") do |type, name|
  value = Server.current_request[:body]["events"].first["breadcrumbs"]
  found = false
  value.each do |crumb|
    if crumb["type"] == type and crumb["name"] == name then
      found = true
    end
  end
  fail("No breadcrumb matched: #{value}") unless found
end
Then("the event has a {string} breadcrumb with message {string}") do |type, message|
  value = Server.current_request[:body]["events"].first["breadcrumbs"]
  found = false
  value.each do |crumb|
    if crumb["type"] == type and crumb["metaData"] and crumb["metaData"]["message"] == message then
      found = true
    end
  end
  fail("No breadcrumb matched: #{value}") unless found
end

## EXCEPTION ASSERTIONS
Then("the exception {string} starts with {string}") do |field, string_value|
  step "the payload field \"events.0.exceptions.0.#{field}\" starts with \"#{string_value}\""
end
Then("the exception {string} ends with {string}") do |field, string_value|
  step "the payload field \"events.0.exceptions.0.#{field}\" ends with \"#{string_value}\""
end
Then("the exception {string} equals {string}") do |field, string_value|
  step "the payload field \"events.0.exceptions.0.#{field}\" equals \"#{string_value}\""
end
Then("the exception {string} matches {string}") do |field, pattern|
  step "the payload field \"events.0.exceptions.0.#{field}\" matches the regex \"#{pattern}\""
end

## STACK FRAME ASSERTIONS
Then("the {string} of stack frame {int} equals {int}") do |key, num, value|
  field = "events.0.exceptions.0.stacktrace.#{num}.#{key}"
  step "the payload field \"#{field}\" equals #{value}"
end
Then("the {string} of stack frame {int} matches {string}") do |key, pattern|
  field = "events.0.exceptions.0.stacktrace.#{num}.#{key}"
  step "the payload field \"#{field}\" matches the regex \"#{pattern}\""
end
Then("the {string} of stack frame {int} equals {string}") do |key, num, value|
  field = "events.0.exceptions.0.stacktrace.#{num}.#{key}"
  step "the payload field \"#{field}\" equals \"#{value}\""
end
Then("the {string} of stack frame {int} starts with {string}") do |key, num, value|
  field = "events.0.exceptions.0.stacktrace.#{num}.#{key}"
  step "the payload field \"#{field}\" starts with \"#{value}\""
end
Then("the {string} of stack frame {int} ends with {string}") do |key, num, value|
  field = "events.0.exceptions.0.stacktrace.#{num}.#{key}"
  step "the payload field \"#{field}\" ends with \"#{value}\""
end
Then(/^the "(.*)" of stack frame (\d*) is (true|false|null|not null)$/) do |key, num, literal|
  field = "events.0.exceptions.0.stacktrace.#{num}.#{key}"
  step "the payload field \"#{field}\" is #{literal}"
end

## THREAD ASSERTIONS
Then("the thread with name {string} contains the error reporting flag") do |thread_name|
  validate_error_reporting_thread("name", thread_name)
end
Then("the thread with id {string} contains the error reporting flag") do |thread_id|
  validate_error_reporting_thread("id", thread_id)
end
def validate_error_reporting_thread(payload_key, payload_value)
  threads = Server.current_request[:body]["events"].first["threads"]
  assert_kind_of Array, threads
  count = 0

  threads.each do |thread|
    if thread[payload_key].to_s == payload_value && thread["errorReportingThread"] == true
      count += 1
    end
  end
  assert_equal(1, count)
end