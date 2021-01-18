# frozen_string_literal: true

# @!group Payload steps

# Tests the payload body does not match a JSON fixture.
#
# @step_input request_type [String] The type of request (error, session, etc)
# @step_input fixture_path [String] Path to a JSON fixture
Then('the {word} payload body does not match the JSON fixture in {string}') do |request_type, fixture_path|
  payload_value = Maze::Server.list_for(request_type).current[:body]
  expected_value = JSON.parse(open(fixture_path, &:read))
  result = Maze::Compare.value(expected_value, payload_value)
  assert_false(result.equal?, "Payload:\n#{payload_value}\nExpected:#{expected_value}")
end

# Test the payload body matches a JSON fixture.
#
# @step_input request_type [String] The type of request (error, session, etc)
# @step_input fixture_path [String] Path to a JSON fixture
Then('the {word} payload body matches the JSON fixture in {string}') do |request_type, fixture_path|
  payload_value = Maze::Server.list_for(request_type).current[:body]
  expected_value = JSON.parse(open(fixture_path, &:read))
  result = Maze::Compare.value(expected_value, payload_value)
  assert_true(result.equal?,
              "The payload field '#{result.keypath}' does not match the fixture:\n #{result.reasons.join('\n')}")
end

# Test that a payload element matches a JSON fixture.
#
# @step_input request_type [String] The type of request (error, session, etc)
# @step_input field_path [String] Path to the tested element
# @step_input fixture_path [String] Path to a JSON fixture
Then('the {word} payload field {string} matches the JSON fixture in {string}') \
do |request_type, field_path, fixture_path|
  list = Maze::Server.list_for(request_type)
  payload_value = Maze::Helper.read_key_path(list.current[:body], field_path)
  expected_value = JSON.parse(open(fixture_path, &:read))
  result = Maze::Compare.value(expected_value, payload_value)
  assert_true(result.equal?,
              "The payload field '#{result.keypath}' does not match the fixture:\n #{result.reasons.join('\n')}")
end

# Tests that a request element is true.
#
# @step_input request_type [String] The type of request (error, session, etc)
# @step_input field_path [String] Path to the tested element
Then('the {word} payload field {string} is true') do |request_type, field_path|
  list = Maze::Server.list_for(request_type)
  assert_true(Maze::Helper.read_key_path(list.current[:body], field_path))
end

# Tests that a request element is false.
#
# @step_input request_type [String] The type of request (error, session, etc)
# @step_input field_path [String] Path to the tested element
Then('the {word} payload field {string} is false') do |request_type, field_path|
  list = Maze::Server.list_for(request_type)
  assert_false(Maze::Helper.read_key_path(list.current[:body], field_path))
end

# Tests that a request element is null.
#
# @step_input request_type [String] The type of request (error, session, etc)
# @step_input field_path [String] Path to the tested element
Then('the {word} payload field {string} is null') do |request_type, field_path|
  list = Maze::Server.list_for(request_type)
  assert_nil(Maze::Helper.read_key_path(list.current[:body], field_path))
end

# Tests that a request element is not null.
#
# @step_input request_type [String] The type of request (error, session, etc)
# @step_input field_path [String] Path to the tested element
Then('the {word} payload field {string} is not null') do |request_type, field_path|
  list = Maze::Server.list_for(request_type)
  assert_not_nil(Maze::Helper.read_key_path(list.current[:body], field_path))
end

# Tests that a payload element equals an integer.
#
# @step_input request_type [String] The type of request (error, session, etc)
# @step_input field_path [String] Path to the tested element
# @step_input int_value [Integer] The value to test against
Then('the {word} payload field {string} equals {int}') do |request_type, field_path, int_value|
  assert_equal(int_value, Maze::Helper.read_key_path(Maze::Server.list_for(request_type).current[:body], field_path))
end

# Tests the payload field value against an environment variable.
#
# @step_input request_type [String] The type of request (error, session, etc)
# @step_input field_path [String] The payload element to test
# @step_input env_var [String] The environment variable to test against
Then('the {word} payload field {string} equals the environment variable {string}') \
do |request_type, field_path, env_var|
  environment_value = ENV[env_var]
  assert_false(environment_value.nil?, "The environment variable #{env_var} must not be nil")
  list = Maze::Server.list_for(request_type)
  value = Maze::Helper.read_key_path(list.current[:body], field_path)

  assert_equal(environment_value, value)
end

# Tests a payload field contains a number larger than a value.
#
# @step_input request_type [String] The type of request (error, session, etc)
# @step_input field_path [String] The payload element to test
# @step_input int_value [Integer] The value to compare against
Then('the {word} payload field {string} is greater than {int}') do |request_type, field_path, int_value|
  list = Maze::Server.list_for(request_type)
  value = Maze::Helper.read_key_path(list.current[:body], field_path)
  assert_kind_of Integer, value
  assert(value > int_value, "The payload field '#{field_path}' is not greater than '#{int_value}'")
end

# Tests a payload field contains a number smaller than a value.
#
# @step_input request_type [String] The type of request (error, session, etc)
# @step_input field_path [String] The payload element to test
# @step_input int_value [Integer] The value to compare against
Then('the {word} payload field {string} is less than {int}') do |request_type, field_path, int_value|
  list = Maze::Server.list_for(request_type)
  value = Maze::Helper.read_key_path(list.current[:body], field_path)
  assert_kind_of Integer, value
  assert(value < int_value, "The #{request_type} payload field '#{field_path}' is not less than '#{int_value}'")
end

# Tests a payload field equals a string.
#
# @step_input request_type [String] The type of request (error, session, etc)
# @step_input field_path [String] The payload element to test
# @step_input string_value [String] The string to test against
Then('the {word} payload field {string} equals {string}') do |request_type, field_path, string_value|
  list = Maze::Server.list_for(request_type)
  assert_equal(string_value, Maze::Helper.read_key_path(list.current[:body], field_path))
end

# Tests a payload field starts with a string.
#
# @step_input request_type [String] The type of request (error, session, etc)
# @step_input field_path [String] The payload element to test
# @step_input string_value [String] The string to test against
Then('the {word} payload field {string} starts with {string}') do |request_type, field_path, string_value|
  list = Maze::Server.list_for(request_type)
  value = Maze::Helper.read_key_path(list.current[:body], field_path)
  assert_kind_of String, value
  assert(value.start_with?(string_value),
         "Field '#{field_path}' value ('#{value}') does not start with '#{string_value}'")
end

# Tests a payload field ends with a string.
#
# @step_input request_type [String] The type of request (error, session, etc)
# @step_input field_path [String] The payload element to test
# @step_input string_value [String] The string to test against
Then('the {word} payload field {string} ends with {string}') do |request_type, field_path, string_value|
  list = Maze::Server.list_for(request_type)
  value = Maze::Helper.read_key_path(list.current[:body], field_path)
  assert_kind_of String, value
  assert(value.end_with?(string_value),
         "Field '#{field_path}' does not end with '#{string_value}'")
end

# Tests a payload field is an array with a specific element count.
#
# @step_input request_type [String] The type of request (error, session, etc)
# @step_input field [String] The payload element to test
# @step_input count [Integer] The value expected
Then('the {word} payload field {string} is an array with {int} elements') do |request_type, field, count|
  list = Maze::Server.list_for(request_type)
  value = Maze::Helper.read_key_path(list.current[:body], field)
  assert_kind_of Array, value
  assert_equal(count, value.length)
end

# Tests a payload field is an array with at least one element.
#
# @step_input request_type [String] The type of request (error, session, etc)
# @step_input field [String] The payload element to test
Then('the {word} payload field {string} is a non-empty array') do |request_type, field|
  list = Maze::Server.list_for(request_type)
  value = Maze::Helper.read_key_path(list.current[:body], field)
  assert_kind_of Array, value
  assert(value.length.positive?,
         "the field '#{field}' must be a non-empty array")
end

# Tests a payload field matches a regex.
#
# @step_input request_type [String] The type of request (error, session, etc)
# @step_input field [String] The payload element to test
# @step_input regex [String] The regex to test against
Then('the {word} payload field {string} matches the regex {string}') do |request_type, field, regex_string|
  regex = Regexp.new(regex_string)
  list = Maze::Server.list_for(request_type)
  value = Maze::Helper.read_key_path(list.current[:body], field)
  assert_match(regex, value)
end

# Tests a payload field is a numeric timestamp.
#
# @step_input request_type [String] The type of request (error, session, etc)
# @step_input field [String] The payload element to test
Then('the {word} payload field {string} is a parsable timestamp in seconds') do |request_type, field|
  list = Maze::Server.list_for(request_type)
  value = Maze::Helper.read_key_path(list.current[:body], field)
  begin
    int = value.to_i
    parsed_time = Time.at(int)
  rescue StandardError
    parsed_time = nil
  end
  assert_not_nil(parsed_time)
end

# Tests that every element in an array contains a specified key-value pair.
#
# @step_input request_type [String] The type of request (error, session, etc)
# @step_input key_path [String] The path to the tested array
# @step_input element_key_path [String] The key for the expected element inside the array
Then('each element in {word} payload field {string} has {string}') do |request_type, key_path, element_key_path|
  list = Maze::Server.list_for(request_type)
  value = Maze::Helper.read_key_path(list.current[:body], key_path)
  assert_kind_of Array, value
  value.each do |element|
    assert_not_nil(Maze::Helper.read_key_path(element, element_key_path),
                   "Each element in '#{key_path}' must have '#{element_key_path}'")
  end
end

