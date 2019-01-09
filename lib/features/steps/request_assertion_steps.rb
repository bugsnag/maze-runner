require 'test/unit'
require 'minitest'
require 'open-uri'
require 'json'
require 'cgi'

include Test::Unit::Assertions

timestamp_regex = /^\d{4}\-\d{2}\-\d{2}T\d{2}:\d{2}:[\d\.]+Z?$/

def find_request(request_index)
  request_index ||= 0
  return stored_requests[request_index]
end

# because WEBrick doesn't populate request.query for use in do_POST methods…
# (only for methods HEAD, GET etc.)
# http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/281361
def parse_querystring(request)
  CGI.parse(request[:request].query_string)
end

Then(/^I should receive (\d+) requests?$/) do |request_count|
  assert_equal(request_count, stored_requests.size, "#{stored_requests.size} requests received")
end
Then(/^I should receive a request$/) do
  step "I should receive 1 request"
end
Then(/^I should receive no requests$/) do
  step "I should receive 0 request"
end
Then(/^the "(.+)" header is not null(?: for request (\d+))?$/) do |header_name, request_index|
  assert_not_nil(find_request(request_index)[:request][header_name],
                "The '#{header_name}' header should not be null")
end
Then(/^the "(.+)" header equals "(.+)"(?: for request (\d+))?$/) do |header_name, header_value, request_index|
  assert_equal(header_value, find_request(request_index)[:request][header_name])
end

Then(/^the "(.+)" header(?: for request (\d+))? equals one of:$/) do |header_name, request_index, header_values|
  assert_includes(header_values.raw.flatten, find_request(request_index)[:request][header_name])
end

Then(/^the "(.+)" header is a timestamp(?: for request (\d+))?$/) do |header_name, request_index|
  header = find_request(request_index)[:request][header_name]
  assert_match(timestamp_regex, header)
end

Then(/^the "(.+)" query parameter equals "(.+)"(?: for request (\d+))?$/) do |parameter_name, parameter_value, request_index|
  assert_equal(parameter_value, parse_querystring(find_request(request_index))[parameter_name][0])
end

Then(/^the "(.+)" query parameter is not null(?: for request (\d+))?$/) do |parameter_name, request_index|
  assert_not_nil(parse_querystring(find_request(request_index))[parameter_name][0], "The '#{parameter_name}' query parameter should not be null")
end

Then(/^the "(.+)" query parameter is a timestamp(?: for request (\d+))?$/) do |parameter_name, request_index|
  param = parse_querystring(find_request(request_index))[parameter_name][0]
  assert_match(timestamp_regex, param)
end

Then(/^the request (\d+) is valid for the Build API$/) do |request_index|
  body = find_request(request_index)[:body]
  assert_not_nil(read_key_path(body, "apiKey"))
  assert_not_nil(read_key_path(body, "appVersion"))
end

Then(/^the request (\d+) is valid for the Android Mapping API$/) do |request_index|
  parts = find_request(request_index)[:body]
  assert_not_nil(parts["proguard"], "'proguard' should not be nil")
  assert_not_nil(parts["apiKey"], "'apiKey' should not be nil")
  assert_not_nil(parts["appId"], "'appId' should not be nil")
  assert_not_nil(parts["versionCode"], "'versionCode' should not be nil")
  assert_not_nil(parts["buildUUID"], "'buildUUID' should not be nil")
  assert_not_nil(parts["versionName"], "'versionName' should not be nil")
end


Then(/^the multipart request (\d+) has (\d+) fields$/) do |request_index, part_count|
  parts = find_request(request_index)[:body]
  assert_equal(part_count, parts.size)
end

Then(/^the field "(.+)" for multipart request (\d+) is not null$/) do |part_key, request_index|
  parts = find_request(request_index)[:body]
  assert_not_nil(parts[part_key], "The field '#{part_key}' should not be null")
end

Then(/^the field "(.+)" for multipart request (\d+) equals "(.+)"$/) do |part_key, request_index, expected_value|
  parts = find_request(request_index)[:body]
  assert_equal(parts[part_key], expected_value)
end

Then(/^the field "(.+)" for multipart request (\d+) is null$/) do |part_key, request_index|
  parts = find_request(request_index)[:body]
  assert_nil(parts[part_key], "The field '#{part_key}' should be null")
end

Then(/^the payload body does not match the JSON fixture in "(.+)"(?: for request (\d+))?$/) do |fixture_path, request_index|
  payload_value = find_request(request_index)[:body]
  expected_value = JSON.parse(open(fixture_path, &:read))
  result = value_compare(expected_value, payload_value)
  assert_false(result.equal?, "Payload:\n#{payload_value}\nExpected:#{expected_value}")
end
Then(/^the payload body matches the JSON fixture in "(.+)"(?: for request (\d+))?$/) do |fixture_path, request_index|
  payload_value = find_request(request_index)[:body]
  expected_value = JSON.parse(open(fixture_path, &:read))
  result = value_compare(expected_value, payload_value)
  assert_true(result.equal?, "The payload field '#{result.keypath}' does not match the fixture:\n #{result.reasons.join('\n')}")
end
Then(/^the payload field "(.+)" matches the JSON fixture in "(.+)"(?: for request (\d+))?$/) do |field_path, fixture_path, request_index|
  payload_value = read_key_path(find_request(request_index)[:body], field_path)
  expected_value = JSON.parse(open(fixture_path, &:read))
  result = value_compare(expected_value, payload_value)
  assert_true(result.equal?, "The payload field '#{result.keypath}' does not match the fixture:\n #{result.reasons.join('\n')}")
end
Then(/^the payload field "(.+)" is true(?: for request (\d+))?$/) do |field_path, request_index|
  assert_equal(true, read_key_path(find_request(request_index)[:body], field_path))
end
Then(/^the payload field "(.+)" is false(?: for request (\d+))?$/) do |field_path, request_index|
  assert_equal(false, read_key_path(find_request(request_index)[:body], field_path))
end

Then(/^the payload field "(.+)" is null(?: for request (\d+))?$/) do |field_path, request_index|
  value = read_key_path(find_request(request_index)[:body], field_path)
  assert_nil(value, "The field '#{field_path}' should be null but is #{value}")
end
Then(/^the payload field "(.+)" is not null(?: for request (\d+))?$/) do |field_path, request_index|
  assert_not_nil(read_key_path(find_request(request_index)[:body], field_path),
                "The field '#{field_path}' should not be null")
end
Then(/^the payload field "(.+)" equals (\d+)(?: for request (\d+))?$/) do |field_path, int_value, request_index|
  assert_equal(int_value, read_key_path(find_request(request_index)[:body], field_path))
end
Then(/^the payload field "(.+)" equals "(.+)"(?: for request (\d+))?$/) do |field_path, string_value, request_index|
  assert_equal(string_value, read_key_path(find_request(request_index)[:body], field_path))
end
Then(/^the payload field "(.+)" starts with "(.+)"(?: for request (\d+))?$/) do |field_path, string_value, request_index|
  value = read_key_path(find_request(request_index)[:body], field_path)
  assert_kind_of String, value
  assert(value.start_with?(string_value), "Field '#{field_path}' value ('#{value}') does not start with '#{string_value}'")
end
Then(/^the payload field "(.+)" ends with "(.+)"(?: for request (\d+))?$/) do |field_path, string_value, request_index|
  value = read_key_path(find_request(request_index)[:body], field_path)
  assert_kind_of String, value
  assert(value.end_with? string_value, "Field '#{field_path}' does not end with '#{string_value}'")
end
Then(/^the payload field "(.+)" is an array with (\d+) elements?(?: for request (\d+))?$/) do |field, count, request_index|
  value = read_key_path(find_request(request_index)[:body], field)
  assert_kind_of Array, value
  assert_equal(count, value.length)
end
Then(/^the payload field "(.+)" is a non-empty array(?: for request (\d+))?$/) do |field, request_index|
  value = read_key_path(find_request(request_index)[:body], field)
  assert_kind_of Array, value
  assert(value.length > 0, "the field '#{field}' must be a non-empty array")
end
Then(/^the payload field "(.+)" matches the regex "(.+)"(?: for request (\d+))?$/) do |field, regex_string, request_index|
  regex = Regexp.new(regex_string)
  value = read_key_path(find_request(request_index)[:body], field)
  assert_match(regex, value)
end
Then(/^the payload field "(.+)" is a parsable timestamp in seconds(?: for request (\d+))?$/) do |field, request_index|
  value = read_key_path(find_request(request_index)[:body], field)
  begin
    int = value.to_i
    parsed_time = Time.at(int)
  rescue => exception
  end
  assert_not_nil(parsed_time)
end

Then("the payload field {string} of request {int} equals the payload field {string} of request {int}") do |field1, request_index1, field2, request_index2|
  value1 = read_key_path(find_request(request_index1)[:body], field1)
  value2 = read_key_path(find_request(request_index2)[:body], field2)
  assert_equal(value1, value2)
end

Then("the payload field {string} of request {int} does not equal the payload field {string} of request {int}") do |field1, request_index1, field2, request_index2|
  value1 = read_key_path(find_request(request_index1)[:body], field1)
  value2 = read_key_path(find_request(request_index2)[:body], field2)
  assert_not_equal(value1, value2)
end

Then(/^the payload has a valid sessions array(?: for request (\d+))?$/) do |request_index|
  body = find_request(request_index)[:body]
  if sessions = read_key_path(body, "sessions")
    assert_kind_of Array, sessions
    assert(sessions.length > 0, "the payload must contain a non empty sessions array")
    assert_not_nil(read_key_path(sessions, "0.id"))
    assert_not_nil(read_key_path(sessions, "0.startedAt"))
  elsif sessionCounts = read_key_path(body, "sessionCounts")
    assert_kind_of Array, sessionCounts
    assert(sessionCounts.length > 0, "the payload must contain a non empty sessionCounts array")
    assert_not_nil(read_key_path(sessionCounts, "0.sessionsStarted"))
    assert_not_nil(read_key_path(sessionCounts, "0.startedAt"))
  else
    fail("the payload must contain a non empty sessions or sessionCounts array")
  end
end

Then(/^each element in payload field "(.+)" has "(.+)"(?: for request (\d+))?$/) do |key_path, element_key_path, request_index|
  value = read_key_path(find_request(request_index)[:body], key_path)
  assert_kind_of Array, value
  value.each do |element|
    assert_not_nil(read_key_path(element, element_key_path),
           "Each element in '#{key_path}' must have '#{element_key_path}'")
  end
end

Then(/^the thread with name "(.+)" contains the error reporting flag?(?: for request (\d+))?$/) do |thread_name, request_index|
  validate_error_reporting_thread("name", thread_name, request_index)
end

Then(/^the thread with id "(.+)" contains the error reporting flag?(?: for request (\d+))?$/) do |thread_id, request_index|
  validate_error_reporting_thread("id", thread_id, request_index)
end

def validate_error_reporting_thread(payload_key, payload_value, request_index)
  threads = read_key_path(find_request(request_index)[:body], "events.0.threads")
  assert_kind_of Array, threads
  count = 0

  threads.each do |thread|
    if thread[payload_key].to_s == payload_value && thread["errorReportingThread"] == true
      count += 1
    end
  end
  assert_equal(1, count)
end

Then(/^I wait to receive a request$/) do
  step "I wait to receive 1 request"
end

Then(/^I wait to receive (\d+) requests?$/) do |request_count|
  max_attempts = 50
  attempts = 0
  received = false
  until (attempts >= max_attempts) || received
    attempts += 1
    received = (stored_requests.size == request_count)
    sleep 0.2
  end
  raise "Requests not received in 10s (received #{stored_requests.size})" unless received
  # Wait an extra second to ensure there are no further requests
  sleep 1
  assert_equal(request_count, stored_requests.size, "#{stored_requests.size} requests received")
end
