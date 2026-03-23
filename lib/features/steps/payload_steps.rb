# frozen_string_literal: true

# @!group Payload steps

# Tests the payload body does not match a JSON fixture.
#
# @step_input request_type [String] The type of request (error, session, build, etc)
# @step_input fixture_path [String] Path to a JSON fixture
Then('the {request_type} payload body does not match the JSON fixture in {string}') do |request_type, fixture_path|
  payload_value = Maze::Server.list_for(request_type).current[:body]
  expected_value = JSON.parse(File.open(fixture_path, &:read))
  result = Maze::Compare.value(expected_value, payload_value)
  Maze.check.false(result.equal?, "Payload:\n#{payload_value}\nExpected:#{expected_value}")
end

# Test the payload body matches a JSON fixture.
#
# @step_input request_type [String] The type of request (error, session, build, etc)
# @step_input fixture_path [String] Path to a JSON fixture
Then('the {request_type} payload body matches the JSON fixture in {string}') do |request_type, fixture_path|
  payload_value = Maze::Server.list_for(request_type).current[:body]
  expected_value = JSON.parse(File.open(fixture_path, &:read))
  result = Maze::Compare.value(expected_value, payload_value)
  Maze.check.true(result.equal?,
                  "The payload field '#{result.keypath}' does not match the fixture:\n #{result.reasons.join('\n')}")
end

# Test that a payload element matches a JSON fixture.
#
# @step_input request_type [String] The type of request (error, session, build, etc)
# @step_input field_path [String] Path to the tested element
# @step_input fixture_path [String] Path to a JSON fixture
Then('the {request_type}(|a b) payload field {string} matches the JSON fixture in {string}') \
do |request_type, field_path, fixture_path|
  list = Maze::Server.list_for(request_type)
  payload_value = Maze::Helper.read_key_path(list.current[:body], field_path)
  expected_value = JSON.parse(File.open(fixture_path, &:read))
  result = Maze::Compare.value(expected_value, payload_value)
  Maze.check.true(result.equal?,
                  "The payload field '#{result.keypath}' does not match the fixture:\n #{result.reasons.join('\n')}")
end

# Tests that a request element is true.
#
# @step_input request_type [String] The type of request (error, session, build, etc)
# @step_input field_path [String] Path to the tested element
Then('the {request_type} payload field {string} is true') do |request_type, field_path|
  list = Maze::Server.list_for(request_type)
  Maze.check.true(Maze::Helper.read_key_path(list.current[:body], field_path))
end

# Tests that a request element is false.
#
# @step_input request_type [String] The type of request (error, session, build, etc)
# @step_input field_path [String] Path to the tested element
Then('the {request_type} payload field {string} is false') do |request_type, field_path|
  list = Maze::Server.list_for(request_type)
  Maze.check.false(Maze::Helper.read_key_path(list.current[:body], field_path))
end

# Tests that a request element is null.
#
# @step_input request_type [String] The type of request (error, session, build, etc)
# @step_input field_path [String] Path to the tested element
Then('the {request_type} payload field {string} is null') do |request_type, field_path|
  list = Maze::Server.list_for(request_type)
  Maze.check.nil(Maze::Helper.read_key_path(list.current[:body], field_path))
end

# Tests that a request element is not null.
#
# @step_input request_type [String] The type of request (error, session, build, etc)
# @step_input field_path [String] Path to the tested element
Then('the {request_type} payload field {string} is not null') do |request_type, field_path|
  list = Maze::Server.list_for(request_type)
  Maze.check.not_nil(Maze::Helper.read_key_path(list.current[:body], field_path))
end

# Tests that a payload element equals a float.
#
# @step_input request_type [String] The type of request (error, session, build, etc)
# @step_input field_path [String] Path to the tested element
# @step_input float_value [Float] The value to test against
Then('the {request_type} payload field {string} equals {float}') do |request_type, field_path, float_value|
  Maze.check.equal(float_value,
                   Maze::Helper.read_key_path(Maze::Server.list_for(request_type).current[:body], field_path))
end

# Tests that a payload element equals a float, to a given number of decimal places.
#
# @step_input request_type [String] The type of request (error, session, build, etc)
# @step_input field_path [String] Path to the tested element
# @step_input float_value [Float] The value to test against
# @step_input places [Int] The number of decimal places to round the actual value to first
Then('the {request_type} payload field {string} equals {float} to {int} decimal place(s)') do |request_type, field_path, float_value, places|
  body = Maze::Server.list_for(request_type).current[:body]
  rounded_value = Maze::Helper.read_key_path(body, field_path).round places
  Maze.check.equal(float_value,
                   rounded_value)
end

# Tests the payload field value against an environment variable.
#
# @step_input request_type [String] The type of request (error, session, build, etc)
# @step_input field_path [String] The payload element to test
# @step_input env_var [String] The environment variable to test against
Then('the {request_type} payload field {string} equals the environment variable {string}') \
do |request_type, field_path, env_var|
  environment_value = ENV[env_var]
  Maze.check.false(environment_value.nil?, "The environment variable #{env_var} must not be nil")
  list = Maze::Server.list_for(request_type)
  value = Maze::Helper.read_key_path(list.current[:body], field_path)

  Maze.check.equal(environment_value, value)
end

# Tests a payload field contains a number larger than a value.
#
# @step_input request_type [String] The type of request (error, session, build, etc)
# @step_input field_path [String] The payload element to test
# @step_input int_value [Integer] The value to compare against
Then('the {request_type} payload field {string} is greater than {int}') do |request_type, field_path, int_value|
  list = Maze::Server.list_for(request_type)
  value = Maze::Helper.read_key_path(list.current[:body], field_path)
  Maze.check.kind_of Integer, value
  Maze.check.operator(value, :>, int_value, "The payload field '#{field_path}' (#{value}) is not greater than '#{int_value}'")
end

# Tests a payload field contains a number smaller than a value.
#
# @step_input request_type [String] The type of request (error, session, build, etc)
# @step_input field_path [String] The payload element to test
# @step_input int_value [Integer] The value to compare against
Then('the {request_type} payload field {string} is less than {int}') do |request_type, field_path, int_value|
  list = Maze::Server.list_for(request_type)
  value = Maze::Helper.read_key_path(list.current[:body], field_path)
  Maze.check.kind_of Integer, value
  fail_message = "The #{request_type} payload field '#{field_path}' (#{value}) is not less than '#{int_value}'"
  Maze.check.operator(value, :<, int_value, fail_message)
end

# Tests a payload field equals a string.
#
# @step_input request_type [String] The type of request (error, session, build, etc)
# @step_input field_path [String] The payload element to test
# @step_input string_value [String] The string to test against
Then('the {request_type} payload field {string} equals {string}') do |request_type, field_path, string_value|
  list = Maze::Server.list_for(request_type)
  Maze.check.equal(string_value, Maze::Helper.read_key_path(list.current[:body], field_path))
end

# Tests a payload field starts with a string.
#
# @step_input request_type [String] The type of request (error, session, build, etc)
# @step_input field_path [String] The payload element to test
# @step_input string_value [String] The string to test against
Then('the {request_type} payload field {string} starts with {string}') do |request_type, field_path, string_value|
  list = Maze::Server.list_for(request_type)
  value = Maze::Helper.read_key_path(list.current[:body], field_path)
  Maze.check.kind_of String, value
  Maze.check.true(
    value.start_with?(string_value),
    "Field '#{field_path}' value ('#{value}') does not start with '#{string_value}'"
  )
end

# Tests a payload field ends with a string.
#
# @step_input request_type [String] The type of request (error, session, build, etc)
# @step_input field_path [String] The payload element to test
# @step_input string_value [String] The string to test against
Then('the {request_type} payload field {string} ends with {string}') do |request_type, field_path, string_value|
  list = Maze::Server.list_for(request_type)
  value = Maze::Helper.read_key_path(list.current[:body], field_path)
  Maze.check.kind_of String, value
  Maze.check.true(
    value.end_with?(string_value),
    "Field '#{field_path}' value ('#{value}') does not end with '#{string_value}'"
  )
end

# Tests a payload field is an array with a specific element count.
#
# @step_input request_type [String] The type of request (error, session, build, etc)
# @step_input field [String] The payload element to test
# @step_input count [Integer] The value expected
Then('the {request_type} payload field {string} is an array with {int} elements') do |request_type, field, count|
  list = Maze::Server.list_for(request_type)
  value = Maze::Helper.read_key_path(list.current[:body], field)
  Maze.check.kind_of Array, value
  Maze.check.equal(count, value.length)
end

# Tests a payload field is an array with at least one element.
#
# @step_input request_type [String] The type of request (error, session, build, etc)
# @step_input field [String] The payload element to test
Then('the {request_type} payload field {string} is a non-empty array') do |request_type, field|
  list = Maze::Server.list_for(request_type)
  value = Maze::Helper.read_key_path(list.current[:body], field)
  Maze.check.kind_of Array, value
  Maze.check.true(value.length.positive?, "the field '#{field}' must be a non-empty array")
end

# Tests a payload field matches a regex.
#
# @step_input request_type [String] The type of request (error, session, build, etc)
# @step_input field [String] The payload element to test
# @step_input regex [String] The regex to test against
Then('the {request_type} payload field {string} matches the regex {string}') do |request_type, field, regex_string|
  regex = Regexp.new(regex_string)
  list = Maze::Server.list_for(request_type)
  value = Maze::Helper.read_key_path(list.current[:body], field)
  Maze.check.match(regex, value)
end

# Tests a payload field is a numeric timestamp.
#
# @step_input request_type [String] The type of request (error, session, build, etc)
# @step_input field [String] The payload element to test
Then('the {request_type} payload field {string} is a parsable timestamp in seconds') do |request_type, field|
  list = Maze::Server.list_for(request_type)
  value = Maze::Helper.read_key_path(list.current[:body], field)
  begin
    int = value.to_i
    parsed_time = Time.at(int)
  rescue StandardError
    parsed_time = nil
  end
  Maze.check.not_nil(parsed_time)
end

# Tests that every element in an array contains a specified key-value pair.
#
# @step_input request_type [String] The type of request (error, session, build, etc)
# @step_input key_path [String] The path to the tested array
# @step_input element_key_path [String] The key for the expected element inside the array
Then('each element in {request_type} payload field {string} has {string}') do |request_type, key_path, element_key_path|
  list = Maze::Server.list_for(request_type)
  value = Maze::Helper.read_key_path(list.current[:body], key_path)
  Maze.check.kind_of Array, value
  value.each do |element|
    Maze.check.not_nil(Maze::Helper.read_key_path(element, element_key_path),
                       "Each element in '#{key_path}' must have '#{element_key_path}'")
  end
end

