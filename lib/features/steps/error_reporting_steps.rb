def get_request_index(request_index)
  request_index ||= 0
end

Then(/^(?:the )?request (?:(\d+) )?is(?: a)? valid for the error reporting API$/) do |index|
  index = 0 if index.nil?
  steps %Q{
    Then the "Bugsnag-API-Key" header is not null for request #{index}
    And the "Content-Type" header equals "application/json" for request #{index}
    And the "Bugsnag-Payload-Version" header for request #{index} equals one of:
      | 4   |
      | 4.0 |
    And the "Bugsnag-Sent-At" header is a timestamp for request #{index}

    And the payload field "notifier.name" is not null for request #{index}
    And the payload field "notifier.url" is not null for request #{index}
    And the payload field "notifier.version" is not null for request #{index}
    And the payload field "events" is a non-empty array for request #{index}

    And each element in payload field "events" has "severity" for request #{index}
    And each element in payload field "events" has "severityReason.type" for request #{index}
    And each element in payload field "events" has "unhandled" for request #{index}
    And each element in payload field "events" has "exceptions" for request #{index}
  }
end
Then(/^the event "(.+)" is true(?: for request (\d+))?$/) do |field, request_index|
  step "the payload field \"events.0.#{field}\" is true for request #{get_request_index(request_index)}"
end
Then(/^the event "(.+)" is false(?: for request (\d+))?$/) do |field, request_index|
  step "the payload field \"events.0.#{field}\" is false for request #{get_request_index(request_index)}"
end
Then(/^the event "(.+)" equals "(.+)"(?: for request (\d+))?$/) do |field, string_value, request_index|
  step "the payload field \"events.0.#{field}\" equals \"#{string_value}\" for request #{get_request_index(request_index)}"
end
Then(/^the event "(.+)" is not null(?: for request (\d+))?$/) do |field, request_index|
  step "the payload field \"events.0.#{field}\" is not null for request #{get_request_index(request_index)}"
end
Then(/^the event "(.+)" is null(?: for request (\d+))?$/) do |field, request_index|
  step "the payload field \"events.0.#{field}\" is null for request #{get_request_index(request_index)}"
end
Then(/^the event "(.+)" starts with "(.+)"(?: for request (\d+))?$/) do |field, string_value, request_index|
  step "the payload field \"events.0.#{field}\" starts with \"#{string_value}\" for request #{get_request_index(request_index)}"
end
Then(/^the event "(.+)" ends with "(.+)"(?: for request (\d+))?$/) do |field, string_value, request_index|
  step "the payload field \"events.0.#{field}\" ends with \"#{string_value}\" for request #{get_request_index(request_index)}"
end
Then(/^the event "(.+)" matches "(.+)"(?: for request (\d+))?$/) do |field, pattern, request_index|
  step "the payload field \"events.0.#{field}\" matches the regex \"#{pattern}\" for request #{get_request_index(request_index)}"
end
Then(/^the event "(.+)" is a timestamp(?: for request (\d+))?$/) do |field, request_index|
  timestamp_regex = /^\d{4}\-\d{2}\-\d{2}T\d{2}:\d{2}:[\d\.]+Z?$/
  step "the payload field \"events.0.#{field}\" matches the regex \"#{timestamp_regex}\" for request #{get_request_index(request_index)}"
end
Then(/^the event "(.+)" is a parsable timestamp in seconds(?: for request (\d+))?$/) do |field, request_index|
  step "the payload field \"events.0.#{field}\" is a parsable timestamp in seconds for request #{get_request_index(request_index)}"
end
Then(/^the event "(.+)" matches the JSON fixture in "(.+)"(?: for request (\d+))?$/) do |field, fixture_path, request_index|
  step "the payload field \"events.0.#{field}\" matches the JSON fixture in \"#{fixture_path}\" for request #{get_request_index(request_index)}"
end
Then(/^the event has a "(.+)" breadcrumb named "(.+)"(?: for request (\d+))?$/) do |type, name, request_index|
  value = read_key_path(find_request(get_request_index(request_index)[:body], "events.0.breadcrumbs")
  found = false
  value.each do |crumb|
    if crumb["type"] == type and crumb["name"] == name then
      found = true
    end
  end
  fail("No breadcrumb matched: #{value}") unless found
end

Then(/^the event has a "(.+)" breadcrumb with message "(.+)"(?: for request (\d+))?$/) do |type, message, request_index|
  value = read_key_path(get_request_index(request_index)[:body], "events.0.breadcrumbs")
  found = false
  value.each do |crumb|
    if crumb["type"] == type and crumb["metaData"] and crumb["metaData"]["message"] == message then
      found = true
    end
  end
  fail("No breadcrumb matched: #{value}") unless found
end

Then(/^the event "([^"]+)" equals (\d+)(?: for request (\d+))?$/) do |field, value, request_index|
  step "the payload field \"events.0.#{field}\" equals #{value} for request #{get_request_index(request_index)}"
end

Then(/^the exception "(.+)" starts with "(.+)"$/) do |field, string_value|
  step "the payload field \"events.0.exceptions.0.#{field}\" starts with \"#{string_value}\""
end
Then(/^the exception "(.+)" ends with "(.+)"$/) do |field, string_value|
  step "the payload field \"events.0.exceptions.0.#{field}\" ends with \"#{string_value}\""
end
Then(/^the exception "(.+)" equals "(.+)"$/) do |field, string_value|
  step "the payload field \"events.0.exceptions.0.#{field}\" equals \"#{string_value}\""
end
Then(/^the exception "(.+)" matches "(.+)"$/) do |field, pattern|
  step "the payload field \"events.0.exceptions.0.#{field}\" matches the regex \"#{pattern}\""
end

Then(/^the "(.+)" of stack frame (\d+) equals (\d+)$/) do |key, num, value|
  field = "events.0.exceptions.0.stacktrace.#{num}.#{key}"
  step "the payload field \"#{field}\" equals #{value}"
end
Then(/^the "(.+)" of stack frame (\d+) matches "(.+)"$/) do |key, pattern|
  field = "events.0.exceptions.0.stacktrace.#{num}.#{key}"
  step "the payload field \"#{field}\" matches the regex \"#{pattern}\""
end
Then(/^the "(.+)" of stack frame (\d+) equals "(.+)"$/) do |key, num, value|
  field = "events.0.exceptions.0.stacktrace.#{num}.#{key}"
  step "the payload field \"#{field}\" equals \"#{value}\""
end
Then(/^the "(.+)" of stack frame (\d+) starts with "(.+)"$/) do |key, num, value|
  field = "events.0.exceptions.0.stacktrace.#{num}.#{key}"
  step "the payload field \"#{field}\" starts with \"#{value}\""
end
Then(/^the "(.+)" of stack frame (\d+) ends with "(.+)"$/) do |key, num, value|
  field = "events.0.exceptions.0.stacktrace.#{num}.#{key}"
  step "the payload field \"#{field}\" ends with \"#{value}\""
end
Then(/^the "(.+)" of stack frame (\d+) is (true|false|null|not null)$/) do |key, num, literal|
  field = "events.0.exceptions.0.stacktrace.#{num}.#{key}"
  step "the payload field \"#{field}\" is #{literal}"
end
