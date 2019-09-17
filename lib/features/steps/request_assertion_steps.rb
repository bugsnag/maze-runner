require 'test/unit'
require 'minitest'
require 'open-uri'
require 'json'
require 'cgi'

include Test::Unit::Assertions

# Parses a request's query string, because WEBrick doesn't in POST requests
#
# @param request [Hash] The received request
#
# @return [Hash] The parsed query string.
def parse_querystring(request)
  CGI.parse(request[:request].query_string)
end

# Enables traversal of a hash using Mongo-style dot notation.
#
# @example hash["array"][0]["item"] becomes "hash.array.0.item"
#
# @param hash [Hash] The hash to traverse
# @param key_path [String] The dot notation path within the hash
#
# @return [Any] The value found by the key path
def read_key_path(hash, key_path)
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

# @!group Request assertion steps

# Shortcut to waiting to receive a single request
Then("I wait to receive a request") do
  step "I wait to receive 1 request"
end

# Continually checks to see if the required amount of requests have been received. Times out after 30 seconds.
#
# @step_input request_count [Integer] The amount of requests expected
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

# Assert that the test Server hasn't received any requests.
Then("I should receive no requests") do
  assert_equal(0, Server.stored_requests.size, "#{Server.stored_requests.size} requests received")
end

# Shifts the received request, dropping the oldest request each time.
Then("I discard the oldest request") do
  Server.stored_requests.shift
end

# Tests that a header is not null
#
# @step_input header_name [String] The header to test
Then("the {string} header is not null") do |header_name|
  assert_not_nil(Server.current_request[:request][header_name],
                "The '#{header_name}' header should not be null")
end

# Tests that a header equals a string
#
# @step_input header_name [String] The header to test
# @step_input header_value [String] The string it should match
Then("the {string} header equals {string}") do |header_name, header_value|
  assert_equal(header_value, Server.current_request[:request][header_name])
end

# Tests that a header matches one of a list of strings
#
# @step_input header_name [String] The header to test
# @step_input header_values [DataTable] A parsed data table
Then("the {string} header equals one of:") do |header_name, header_values|
  assert_includes(header_values.raw.flatten, Server.current_request[:request][header_name])
end

# Tests that a header is a timestamp.
#   Uses the regex /^\d{4}\-\d{2}\-\d{2}T\d{2}:\d{2}:[\d\.]+Z?$/
#
# @step_input header_name [String] The header to test
Then("the {string} header is a timestamp") do |header_name|
  header = Server.current_request[:request][header_name]
  assert_match(TIMESTAMP_REGEX, header)
end

# Tests that a query parameter matches a string.
#
# @step_input parameter_name [String] The parameter to test
# @step_input parameter_value [String] The expected value
Then("the {string} query parameter equals {string}") do |parameter_name, parameter_value|
  assert_equal(parameter_value, parse_querystring(Server.current_request)[parameter_name][0])
end

# Tests that a query parameter is present and not null.
#
# @step_input parameter_name [String] The parameter to test
Then("the {string} query parameter is not null") do |parameter_name|
  assert_not_nil(parse_querystring(Server.current_request)[parameter_name][0], "The '#{parameter_name}' query parameter should not be null")
end

# Tests that a query parameter is a timestamp.
#   Uses the regex /^\d{4}\-\d{2}\-\d{2}T\d{2}:\d{2}:[\d\.]+Z?$/
#
# @step_input parameter_naem [String] The parameter to test
Then("the {string} query parameter is a timestamp") do |parameter_name|
  param = parse_querystring(Server.current_request)[parameter_name][0]
  assert_match(TIMESTAMP_REGEX, param)
end

# Tests the number of fields a multipart request contains.
#
# @step_input part_count [Integer] The number of expected feilds
Then("the multipart request has {int} fields") do |part_count|
  parts = Server.current_request[:body]
  assert_equal(part_count, parts.size)
end

# Tests that a multipart request field exists and is not null.
#
# @step_input part_key [String] The key to the multipart element
Then("the field {string} for multipart request is not null") do |part_key|
  parts = Server.current_request[:body]
  assert_not_nil(parts[part_key], "The field '#{part_key}' should not be null")
end

# Tests that a multipart request field equals a string.
#
# @step_input part_key [String] The key to the multipart element
# @step_input expected_value [String] The string to match against
Then("the field {string} for multipart request equals {string}") do |part_key, expected_value|
  parts = Server.current_request[:body]
  assert_equal(parts[part_key], expected_value)
end

# Tests that a multipart request field is null.
#
# @step_input part_key [String] The key to the multipart element
Then("the field {string} for multipart request is null") do |part_key|
  parts = Server.current_request[:body]
  assert_nil(parts[part_key], "The field '#{part_key}' should be null")
end

# Tests the payload body does not match a JSON fixture.
#
# @step_input fixture_path [String] Path to a JSON fixture
Then("the payload body does not match the JSON fixture in {string}") do |fixture_path|
  payload_value = Server.current_request[:body]
  expected_value = JSON.parse(open(fixture_path, &:read))
  result = value_compare(expected_value, payload_value)
  assert_false(result.equal?, "Payload:\n#{payload_value}\nExpected:#{expected_value}")
end

# Test the payload body matches a JSON fixture.
#
# @step_input fixture_path [String] Path to a JSON fixture
Then("the payload body matches the JSON fixture in {string}") do |fixture_path|
  payload_value = Server.current_request[:body]
  expected_value = JSON.parse(open(fixture_path, &:read))
  result = value_compare(expected_value, payload_value)
  assert_true(result.equal?, "The payload field '#{result.keypath}' does not match the fixture:\n #{result.reasons.join('\n')}")
end

# Test that a payload element matches a JSON fixture.
#
# @step_input field_path [String] Path to the tested element
# @step_input fixture_path [String] Path to a JSON fixture
Then("the payload field {string} matches the JSON fixture in {string}") do |field_path, fixture_path|
  payload_value = read_key_path(Server.current_request[:body], field_path)
  expected_value = JSON.parse(open(fixture_path, &:read))
  result = value_compare(expected_value, payload_value)
  assert_true(result.equal?, "The payload field '#{result.keypath}' does not match the fixture:\n #{result.reasons.join('\n')}")
end

# Tests that a payload element is true.
#
# @step_input field_path [String] Path to the tested element
Then("the payload field {string} is true") do |field_path|
  assert_equal(true, read_key_path(Server.current_request[:body], field_path))
end

# Tests that a payload element is false.
#
# @step_input field_path [String] Path to the tested element
Then("the payload field {string} is false") do |field_path|
  assert_equal(false, read_key_path(Server.current_request[:body], field_path))
end

# Tests that a payload element is null.
#
# @step_input field_path [String] Path to the tested element
Then("the payload field {string} is null") do |field_path|
  value = read_key_path(Server.current_request[:body], field_path)
  assert_nil(value, "The field '#{field_path}' should be null but is #{value}")
end

# Tests that a payload element is not null.
#
# @step_input field_path [String] Path to the tested element
Then("the payload field {string} is not null") do |field_path|
  assert_not_nil(read_key_path(Server.current_request[:body], field_path),
                "The field '#{field_path}' should not be null")
end

# Tests that a payload element equals an integer.
#
# @step_input field_path [String] Path to the tested element
# @step_input int_value [Integer] The value to test against
Then("the payload field {string} equals {int}") do |field_path, int_value|
  assert_equal(int_value, read_key_path(Server.current_request[:body], field_path))
end

# Tests the payload field value against an environment variable.
#
# @step_input field_path [String] The payload element to test
# @step_input env_var [String] The environment variable to test against
Then("the payload field {string} equals the environment variable {string}") do |field_path, env_var|
  environment_value = ENV[env_var]
  assert_false(environment_value.nil?, "The environment variable #{env_var} must not be nil")
  value = read_key_path(Server.current_request[:body], field_path)

  assert_equal(environment_value, value)
end

# Tests a payload field contains a number larger than a value.
#
# @step_input field_path [String] The payload element to test
# @step_input int_value [Integer] The value to compare against
Then("the payload field {string} is greater than {int}") do |field_path, int_value|
  value = read_key_path(Server.current_request[:body], field_path)
  assert_kind_of Integer, value
  assert(value > int_value, "The payload field '#{field_path}' is not greater than '#{int_value}'")
end

# Tests a payload field contains a number smaller than a value.
#
# @step_input field_path [String] The payload element to test
# @step_input int_value [Integer] The value to compare against
Then("the payload field {string} is less than {int}") do |field_path, int_value|
  value = read_key_path(Server.current_request[:body], field_path)
  assert_kind_of Integer, value
  assert(value < int_value, "The payload field '#{field_path}' is not less than '#{int_value}'")
end

# Tests a payload field equals a string.
#
# @step_input field_path [String] The payload element to test
# @step_input string_value [String] The string to test against
Then("the payload field {string} equals {string}") do |field_path, string_value|
  assert_equal(string_value, read_key_path(Server.current_request[:body], field_path))
end

# Tests a payload field starts with a string.
#
# @step_input field_path [String] The payload element to test
# @step_input string_value [String] The string to test against
Then("the payload field {string} starts with {string}") do |field_path, string_value|
  value = read_key_path(Server.current_request[:body], field_path)
  assert_kind_of String, value
  assert(value.start_with?(string_value), "Field '#{field_path}' value ('#{value}') does not start with '#{string_value}'")
end

# Tests a payload field ends with a string.
#
# @step_input field_path [String] The payload element to test
# @step_input string_value [String] The string to test against
Then("the payload field {string} ends with {string}") do |field_path, string_value|
  value = read_key_path(Server.current_request[:body], field_path)
  assert_kind_of String, value
  assert(value.end_with? string_value, "Field '#{field_path}' does not end with '#{string_value}'")
end

# Tests a payload field is an array with a specific element count.
#
# @step_input field [String] The payload element to test
# @step_input count [Integer] The value expected
Then("the payload field {string} is an array with {int} elements") do |field, count|
  value = read_key_path(Server.current_request[:body], field)
  assert_kind_of Array, value
  assert_equal(count, value.length)
end

# Tests a payload field is an array with at least one element.
#
# @step_input field [String] The payload element to test
Then("the payload field {string} is a non-empty array") do |field|
  value = read_key_path(Server.current_request[:body], field)
  assert_kind_of Array, value
  assert(value.length > 0, "the field '#{field}' must be a non-empty array")
end

# Tests a payload field matches a regex.
#
# @step_input field [String] The payload element to test
# @step_input regex [String] The regex to test against
Then("the payload field {string} matches the regex {string}") do |field, regex_string|
  regex = Regexp.new(regex_string)
  value = read_key_path(Server.current_request[:body], field)
  assert_match(regex, value)
end

# Tests a payload field is a numeric timestamp.
#
# @step_input field [String] The payload element to test
Then("the payload field {string} is a parsable timestamp in seconds") do |field|
  value = read_key_path(Server.current_request[:body], field)
  begin
    int = value.to_i
    parsed_time = Time.at(int)
  rescue => exception
  end
  assert_not_nil(parsed_time)
end

# Tests that every element in an array contains a specified key-value pair.
#
# @step_input key_path [String] The path to the tested array
# @step_input element_key_path [String] The key for the expected element inside the array
Then("each element in payload field {string} has {string}") do |key_path, element_key_path|
  value = read_key_path(Server.current_request[:body], key_path)
  assert_kind_of Array, value
  value.each do |element|
    assert_not_nil(read_key_path(element, element_key_path),
           "Each element in '#{key_path}' must have '#{element_key_path}'")
  end
end