def optional_request_index (request_index)
  request_index.nil? ? "" : " for request #{request_index}"
end

Then(/^(?:the )?request(?: (\d+))? is(?: a)? valid for the session tracking API$/) do |request_index|
  steps %Q{
    Then the "Bugsnag-API-Key" header is not null#{optional_request_index(request_index)}
    And the "Content-Type" header equals "application/json"#{optional_request_index(request_index)}
    And the "Bugsnag-Payload-Version" header equals "1.0"#{optional_request_index(request_index)}
    And the "Bugsnag-Sent-At" header is a timestamp#{optional_request_index(request_index)}

    And the payload field "app" is not null#{optional_request_index(request_index)}
    And the payload field "device" is not null#{optional_request_index(request_index)}
    And the payload field "notifier.name" is not null#{optional_request_index(request_index)}
    And the payload field "notifier.url" is not null#{optional_request_index(request_index)}
    And the payload field "notifier.version" is not null#{optional_request_index(request_index)}
    And the payload has a valid sessions array#{optional_request_index(request_index)}
  }
end
Then(/^the session "(.+)" is (true|false|null|not null)(?: for request (\d+))?$/) do |field, literal, request_index|
  step "the payload field \"sessions.0.#{field}\" is #{literal}#{optional_request_index(request_index)}"
end
Then(/^the session "(.+)" equals "(.+)"(?: for request (\d+))?$/) do |field, string_value, request_index|
  step "the payload field \"sessions.0.#{field}\" equals \"#{string_value}\"#{optional_request_index(request_index)}"
end
Then(/^the session "(.+)" is a timestamp(?: for request (\d+))?$/) do |field, request_index|
  timestamp_regex = /^\d{4}\-\d{2}\-\d{2}T\d{2}:\d{2}:[\d\.]+Z?$/
  step "the payload field \"sessions.0.#{field}\" matches the regex \"#{timestamp_regex}\"#{optional_request_index(request_index)}"
end
Then(/^the sessionCount "(.+)" is (true|false|null|not null)$/) do |field, literal, request_index|
  step "the payload field \"sessionCounts.0.#{field}\" is false#{optional_request_index(request_index)}"
end
Then(/^the sessionCount "(.+)" equals "(.+)"(?: for request (\d+))?$/) do |field, string_value, request_index|
  step "the payload field \"sessionCounts.0.#{field}\" equals \"#{string_value}\"#{optional_request_index(request_index)}"
end
Then(/^the sessionCount "(.+)" equals (\d+)(?: for request (\d+))?$/) do |field, int_value, request_index|
  step "the payload field \"sessionCounts.0.#{field}\" equals #{int_value}#{optional_request_index(request_index)}"
end
Then(/^the sessionCount "(.+)" is not null(?: for request (\d+))?$/) do |field, request_index|
  step "the payload field \"sessionCounts.0.#{field}\" is not null#{optional_request_index(request_index)}"
end
Then(/^the sessionCount "(.+)" is null(?: for request (\d+))?$/) do |field, request_index|
  step "the payload field \"sessionCounts.0.#{field}\" is null#{optional_request_index(request_index)}"
end
Then(/^the sessionCount "(.+)" is a timestamp(?: for request (\d+))?$/) do |field, request_index|
  timestamp_regex = /^\d{4}\-\d{2}\-\d{2}T\d{2}:\d{2}:[\d\.]+Z?$/
  step "the payload field \"sessionCounts.0.#{field}\" matches the regex \"#{timestamp_regex}\"#{optional_request_index(request_index)}"
end
