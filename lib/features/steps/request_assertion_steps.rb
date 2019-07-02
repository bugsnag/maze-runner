require 'test/unit'
require 'minitest'
require 'open-uri'
require 'json'
require 'cgi'

include Test::Unit::Assertions

# because WEBrick doesn't populate request.query for use in do_POST methods…
# (only for methods HEAD, GET etc.)
# http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/281361
def parse_querystring(request)
  CGI.parse(request[:request].query_string)
end

# Helper to allow you to use mongo like dot notation to reference fields
def read_key_path hash, key_path
  value = hash
  key_path.split('.').each do |key|
    if key =~ /^(\d+)$/
      key = key.to_i
      if value.length > key
        value = value[key]
      else
        return nil
      end
    else
      if value.keys.include? key
        value = value[key]
      else
        return nil
      end
    end
  end
  value
end

## REQUESTS RECEIVED ASSERTIONS
Then("I wait to receive a request") do
  step "I wait to receive 1 request"
end
Then("I wait to receive {int} request(s)") do |request_count|
  max_attempts = 300
  attempts = 0
  received = false
  until (attempts >= max_attempts) || received
    attempts += 1
    received = (Server.stored_requests.size >= request_count)
    sleep 0.1
  end
  raise "Requests not received in 30s (received #{Server.stored_requests.size})" unless received
  unless Server.stored_requests.size == request_count
    $logger.warn Server.stored_requests.inspect
  end
  assert_equal(request_count, Server.stored_requests.size, "#{Server.stored_requests.size} requests received")
end
Then("I should receive no requests") do
  assert_equal(0, Server.stored_requests.size, "#{Server.stored_requests.size} requests received")
end
Then("I discard the oldest request") do
  Server.stored_requests.shift
end

## HEADER ASSERTIONS
Then("the {string} header is not null") do |header_name|
  assert_not_nil(Server.current_request[:request][header_name],
                "The '#{header_name}' header should not be null")
end
Then("the {string} header equals {string}") do |header_name, header_value|
  assert_equal(header_value, Server.current_request[:request][header_name])
end
Then("the {string} header equals one of:") do |header_name, header_values|
  assert_includes(header_values.raw.flatten, Server.current_request[:request][header_name])
end
Then("the {string} header is a timestamp") do |header_name|
  header = Server.current_request[:request][header_name]
  assert_match(TIMESTAMP_REGEX, header)
end

## QUERY PARAM ASSERTIONS
Then("the {string} query parameter equals {string}") do |parameter_name, parameter_value|
  assert_equal(parameter_value, parse_querystring(Server.current_request)[parameter_name][0])
end
Then("the {string} query parameter is not null") do |parameter_name|
  assert_not_nil(parse_querystring(Server.current_request)[parameter_name][0], "The '#{parameter_name}' query parameter should not be null")
end
Then("the {string} query parameter is a timestamp") do |parameter_name|
  param = parse_querystring(Server.current_request)[parameter_name][0]
  assert_match(TIMESTAMP_REGEX, param)
end

## MULTIPART REQUEST ASSERTIONS
Then("the multipart request has {int} fields") do |part_count|
  parts = Server.current_request[:body]
  assert_equal(part_count, parts.size)
end
Then("the field {string} for multipart request is not null") do |part_key|
  parts = Server.current_request[:body]
  assert_not_nil(parts[part_key], "The field '#{part_key}' should not be null")
end
Then("the field {string} for multipart request equals {string}") do |part_key, expected_value|
  parts = Server.current_request[:body]
  assert_equal(parts[part_key], expected_value)
end
Then("the field {string} for multipart request is null") do |part_key|
  parts = Server.current_request[:body]
  assert_nil(parts[part_key], "The field '#{part_key}' should be null")
end

## JSON FIXTURE ASSERTIONS
Then("the payload body does not match the JSON fixture in {string}") do |fixture_path|
  payload_value = Server.current_request[:body]
  expected_value = JSON.parse(open(fixture_path, &:read))
  result = value_compare(expected_value, payload_value)
  assert_false(result.equal?, "Payload:\n#{payload_value}\nExpected:#{expected_value}")
end
Then("the payload body matches the JSON fixture in {string}") do |fixture_path|
  payload_value = Server.current_request[:body]
  expected_value = JSON.parse(open(fixture_path, &:read))
  result = value_compare(expected_value, payload_value)
  assert_true(result.equal?, "The payload field '#{result.keypath}' does not match the fixture:\n #{result.reasons.join('\n')}")
end
Then("the payload field {string} matches the JSON fixture in {string}") do |field_path, fixture_path|
  payload_value = read_key_path(Server.current_request[:body], field_path)
  expected_value = JSON.parse(open(fixture_path, &:read))
  result = value_compare(expected_value, payload_value)
  assert_true(result.equal?, "The payload field '#{result.keypath}' does not match the fixture:\n #{result.reasons.join('\n')}")
end

## PAYLOAD FIELD ASSERTIONS
Then("the payload field {string} is true") do |field_path|
  assert_equal(true, read_key_path(Server.current_request[:body], field_path))
end
Then("the payload field {string} is false") do |field_path|
  assert_equal(false, read_key_path(Server.current_request[:body], field_path))
end
Then("the payload field {string} is null") do |field_path|
  value = read_key_path(Server.current_request[:body], field_path)
  assert_nil(value, "The field '#{field_path}' should be null but is #{value}")
end
Then("the payload field {string} is not null") do |field_path|
  assert_not_nil(read_key_path(Server.current_request[:body], field_path),
                "The field '#{field_path}' should not be null")
end
Then("the payload field {string} equals {int}") do |field_path, int_value|
  assert_equal(int_value, read_key_path(Server.current_request[:body], field_path))
end

# Checks the payload field value against an environment variable
#
# @param field_path [String] The payload element to check
# @param env_var [String] The environment variable to test against
Then("the payload field {string} equals the environment variable {string}") do |field_path, env_var|
  environment_value = ENV[env_var]
  assert_false(environment_value.nil?, "The environment variable #{env_var} must not be nil")
  value = read_key_path(Server.current_request[:body], field_path)

  assert_equal(environment_value, value)
end

# Checks a given payload field contains a number larger than a given value
#
# @param field_path [String] The payload element to check
# @param int_value [Integer] The value to compare against
Then("the payload field {string} is greater than {int}") do |field_path, int_value|
  value = read_key_path(Server.current_request[:body], field_path)
  assert_kind_of Integer, value
  assert(value > int_value, "The payload field '#{field_path}' is not greater than '#{int_value}'")
end

# Checks a given payload field contains a number smaller than a given value
#
# @param field_path [String] The payload element to check
# @param int_value [Integer] The value to compare against
Then("the payload field {string} is less than {int}") do |field_path, int_value|
  value = read_key_path(Server.current_request[:body], field_path)
  assert_kind_of Integer, value
  assert(value < int_value, "The payload field '#{field_path}' is not less than '#{int_value}'")
end
Then("the payload field {string} equals {string}") do |field_path, string_value|
  assert_equal(string_value, read_key_path(Server.current_request[:body], field_path))
end
Then("the payload field {string} starts with {string}") do |field_path, string_value|
  value = read_key_path(Server.current_request[:body], field_path)
  assert_kind_of String, value
  assert(value.start_with?(string_value), "Field '#{field_path}' value ('#{value}') does not start with '#{string_value}'")
end
Then("the payload field {string} ends with {string}") do |field_path, string_value|
  value = read_key_path(Server.current_request[:body], field_path)
  assert_kind_of String, value
  assert(value.end_with? string_value, "Field '#{field_path}' does not end with '#{string_value}'")
end

# Checks a given payload field is an array with at a certain element count
#
# @param field [String] The payload element to check
# @param count [Integer] The value expected
Then("the payload field {string} is an array with {int} elements") do |field, count|
  value = read_key_path(Server.current_request[:body], field)
  assert_kind_of Array, value
  assert_equal(count, value.length)
end
Then("the payload field {string} is a non-empty array") do |field|
  value = read_key_path(Server.current_request[:body], field)
  assert_kind_of Array, value
  assert(value.length > 0, "the field '#{field}' must be a non-empty array")
end
Then("the payload field {string} matches the regex {string}") do |field, regex_string|
  regex = Regexp.new(regex_string)
  value = read_key_path(Server.current_request[:body], field)
  assert_match(regex, value)
end
Then("the payload field {string} is a parsable timestamp in seconds") do |field|
  value = read_key_path(Server.current_request[:body], field)
  begin
    int = value.to_i
    parsed_time = Time.at(int)
  rescue => exception
  end
  assert_not_nil(parsed_time)
end
Then("each element in payload field {string} has {string}") do |key_path, element_key_path|
  value = read_key_path(Server.current_request[:body], key_path)
  assert_kind_of Array, value
  value.each do |element|
    assert_not_nil(read_key_path(element, element_key_path),
           "Each element in '#{key_path}' must have '#{element_key_path}'")
  end
end

# Checks a given payload field for the current request is the same as a payload field in the next request
#
# @param current_field [String] the payload element from the current request
# @param next_field [String] the payload element in the next request
Then("the payload field {string} in the current request matches the payload field {string} in the next request") do |current_field, next_field|
  assert(Server.stored_requests.length > 1, "The server does not have more than one request")
  current_value = read_key_path(Server.current_request[:body], current_field)
  next_value = read_key_path(Server.next_request[:body], next_field)
  result = value_compare(current_value, next_value)
  assert_true(result.equal?, "The current value #{current_value} did not equal the next value #{next_value}")
end

# Checks a given payload field for the current request is not the same as a payload field in the next request
#
# @param current_field [String] the payload element from the current request
# @param next_field [String] the payload element from the next request
Then("the payload field {string} in the current request does not match the payload field {string} in the next request") do |current_field, next_field|
  assert(Server.stored_requests.length > 1, "The server does not have more than one request")
  current_value = read_key_path(Server.current_request[:body], current_field)
  next_value = read_key_path(Server.next_request[:body], next_field)
  result = value_compare(current_value, next_value)
  assert_false(result.equal?, "The current value #{current_value} equaled the next value #{next_value}")
end