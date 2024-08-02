# @!group Platform dependent steps

# Tests that the given payload value is correct for the target BrowserStack platform.
# This step will assume the expected and payload values are strings.
# If the step is invoked when a remote BrowserStack device is not in use this step will fail.
#
# The DataTable used for this step should have `ios` and `android` in the same row as their expected value:
#   | android | Java.lang.RuntimeException |
#   | ios     | NSException                |
#
# If the expected value is set to "@skip", the check should be skipped
# If the expected value is set to "@null", the check will be for null
# If the expected value is set to "@not_null", the check will be for a non-null value
#
# @step_input request_type [String] The type of request (error, session, build, etc)
# @step_input field_path [String] The field to test
# @step_input platform_values [DataTable] A table of acceptable values for each platform
Then('the {request_type} payload field {string} equals the platform-dependent string:') do |request_type, field_path, platform_values|
  test_string_platform_values(request_type, field_path, platform_values)
end

# See `the error payload field {string} equals the platform-dependent string:`
#
# @step_input field_path [String] The field to test, prepended with "events.0"
# @step_input platform_values [DataTable] A table of acceptable values for each platform
Then('the event {string} equals the platform-dependent string:') do |field_path, platform_values|
  test_string_platform_values('error', "events.0.#{field_path}", platform_values)
end

# Tests that the given payload value is correct for the target BrowserStack platform.
# This step will assume the expected and payload values are numeric.
# If the step is invoked when a remote BrowserStack device is not in use this step will fail.
#
# The DataTable used for this step should have `ios` and `android` in the same row as their expected value:
#   | android | 1  |
#   | ios     | 5.5 |
#
# If the expected value is set to "@skip", the check should be skipped
# If the expected value is set to "@null", the check will be for null
# If the expected value is set to "@not_null", the check will be for a non-null value
#
# @step_input request_type [String] The type of request (error, session, build, etc)
# @step_input field_path [String] The field to test
# @step_input platform_values [DataTable] A table of acceptable values for each platform
Then('the {request_type} payload field {string} equals the platform-dependent numeric:') do |request_type, field_path, platform_values|
  test_numeric_platform_values(request_type, field_path, platform_values)
end

# See `the payload field {string} equals the platform-dependent numeric:`
#
# @step_input field_path [String] The field to test, prepended with "events.0"
# @step_input platform_values [DataTable] A table of acceptable values for each platform
Then('the event {string} equals the platform-dependent numeric:') do |field_path, platform_values|
  test_numeric_platform_values('error', "events.0.#{field_path}", platform_values)
end

# Tests that the given payload value is correct for the target BrowserStack platform.
# This step will assume the expected and payload values are booleans.
# If the step is invoked when a remote BrowserStack device is not in use this step will fail.
#
# The DataTable used for this step should have `ios` and `android` in the same row as their expected value:
#   | android | 1 |
#   | ios     | 5 |
#
# If the expected value is set to "@skip", the check should be skipped
# If the expected value is set to "@null", the check will be for null
# If the expected value is set to "@not_null", the check will be for a non-null value
#
# @step_input request_type [String] The type of request (error, session, build, etc)
# @step_input field_path [String] The field to test
# @step_input platform_values [DataTable] A table of acceptable values for each platform
Then('the {request_type} payload field {string} equals the platform-dependent boolean:') do |request_type, field_path, platform_values|
  test_boolean_platform_values(request_type, field_path, platform_values)
end

# See `the payload field {string} equals the platform-dependent boolean:`
#
# @step_input field_path [String] The field to test, prepended with "events.0"
# @step_input platform_values [DataTable] A table of acceptable values for each platform
Then('the event {string} equals the platform-dependent boolean:') do |field_path, platform_values|
  test_boolean_platform_values('error', "events.0.#{field_path}", platform_values)
end

# See `the payload field {string} equals the platform-dependent string:`
#
# @step_input field_path [String] The field to test, prepended with "events.0.exceptions.0."
# @step_input platform_values [DataTable] A table of acceptable values for each platform
Then('the exception {string} equals the platform-dependent string:') do |field_path, platform_values|
  test_string_platform_values('error', "events.0.exceptions.0.#{field_path}", platform_values)
end

# See `the payload field {string} equals the platform-dependent string:`
#
# @step_input field_path [String] The field to test, prepended with "events.0.exceptions.0.stacktrace.#!{num}"
# @step_input num [Integer] The index of the stack frame to test
# @step_input platform_values [DataTable] A table of acceptable values for each platform
Then('the {string} of stack frame {int} equals the platform-dependent string:') do |field_path, num, platform_values|
  test_string_platform_values('error', "events.0.exceptions.0.stacktrace.#{num}.#{field_path}", platform_values)
end

#
# Equality check routines
#
def test_string_platform_values(request_type, field_path, platform_values)
  expected_value = get_expected_platform_value(platform_values)
  return if should_skip_platform_check(expected_value)

  list = Maze::Server.list_for(request_type)
  payload_value = Maze::Helper.read_key_path(list.current[:body], field_path)
  assert_equal_with_nullability(expected_value, payload_value)
end

def test_boolean_platform_values(request_type, field_path, platform_values)
  expected_value = get_expected_platform_value(platform_values)
  return if should_skip_platform_check(expected_value)

  expected_bool = case expected_value.downcase
                  when 'true'
                    true
                  when 'false'
                    false
                  else
                    expected_value
                  end
  list = Maze::Server.list_for(request_type)
  payload_value = Maze::Helper.read_key_path(list.current[:body], field_path)
  assert_equal_with_nullability(expected_bool, payload_value)
end

def test_numeric_platform_values(request_type, field_path, platform_values)
  expected_value = get_expected_platform_value(platform_values)
  return if should_skip_platform_check(expected_value)

  list = Maze::Server.list_for(request_type)
  payload_value = Maze::Helper.read_key_path(list.current[:body], field_path)

  # Need to do a little more processing here to allow floats
  special_value = expected_value.eql?('@null') || expected_value.eql?('@not_null')
  expectation = special_value ? expected_value : expected_value.to_f
  assert_equal_with_nullability(expectation, payload_value)
end

def assert_equal_with_nullability(expected_value, payload_value)
  case expected_value
  when '@null'
    Maze.check.nil(payload_value)
  when '@not_null'
    Maze.check.not_nil(payload_value)
  else
    Maze.check.equal(expected_value, payload_value)
  end
end

def get_expected_platform_value(platform_values)
  os = Maze::Helper.get_current_platform
  expected_value = Hash[platform_values.raw][os.downcase]
  raise("There is no expected value for the current platform \"#{os}\"") if expected_value.nil?

  expected_value
end

def should_skip_platform_check(expected_value)
  expected_value.eql?('@skip')
end

# @step_input request_type [String] The type of request (error, session, build, etc)
# @step_input field_path [String] The field to test
# @step_input platform_values [DataTable] A table of acceptable regexes for each platform
Then('the {request_type} payload field {string} matches the platform-dependent regex:') do |request_type, field_path, platform_regexes|
  match_string_platform_regexes(request_type, field_path, platform_regexes)
end

# See `the error payload field {string} equals the platform-dependent string:`
#
# @step_input field_path [String] The field to test, prepended with "events.0"
# @step_input platform_values [DataTable] A table of acceptable values for each platform
Then('the event {string} matches the platform-dependent regex:') do |field_path, platform_regexes|
  match_string_platform_regexes('error', "events.0.#{field_path}", platform_regexes)
end

# @step_input field_path [String] The field to test, prepended with "events.0.exceptions.0."
# @step_input platform_values [DataTable] A table of acceptable regexes for each platform
Then('the exception {string} matches the platform-dependent regex:') do |field_path, platform_regexes|
  match_string_platform_regexes('error', "events.0.exceptions.0.#{field_path}", platform_regexes)
end

# @step_input field_path [String] The field to test, prepended with "events.0.exceptions.0.stacktrace.#!{num}"
# @step_input num [Integer] The index of the stack frame to test
# @step_input platform_values [DataTable] A table of acceptable values for each platform
Then('the {string} of stack frame {int} matches the platform-dependent regex:') do |field_path, num, platform_regexes|
  match_string_platform_regexes('error', "events.0.exceptions.0.stacktrace.#{num}.#{field_path}", platform_regexes)
end

#
# Regex match routines
#
def match_string_platform_regexes(request_type, field_path, platform_values)
  expected_regex = get_expected_platform_value(platform_values)
  return if should_skip_platform_check(expected_regex)
  list = Maze::Server.list_for(request_type)
  payload_value = Maze::Helper.read_key_path(list.current[:body], field_path)

  Maze.check.match(expected_regex, payload_value)
end
