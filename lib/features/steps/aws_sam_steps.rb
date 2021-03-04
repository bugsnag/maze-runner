# frozen_string_literal: true

require_relative '../../maze'
require_relative '../../maze/aws/sam'

# @!group AWS SAM steps

# Invoke a lambda directly with 'sam invoke'
#
# @step_input lambda_name [String] The name of the lambda to invoke
# @step_input directory [String] The directory to invoke the lambda in
Given('I invoke the {string} lambda in {string}') do |lambda_name, directory|
  Maze::Aws::Sam.invoke(directory, lambda_name)
end

# Invoke a lambda directly with 'sam invoke' and the given event
#
# @step_input lambda_name [String] The name of the lambda to invoke
# @step_input directory [String] The directory to invoke the lambda in
# @step_input event_file [String] The event file to call the lambda with
Given('I invoke the {string} lambda in {string} with the {string} event') do |lambda_name, directory, event_file|
  Maze::Aws::Sam.invoke(directory, lambda_name, event_file)
end

# Test the exit code of the SAM CLI process.
#
# @step_input expected [Integer] The expected exit code
Then('the SAM exit code equals {int}') do |expected|
  assert_equal(expected, Maze::Aws::Sam.last_exit_code)
end

# Test the Lambda response is empty but not-null. This indicates the Lambda did
# not respond but did run successfully
Then('the lambda response is empty') do
  assert_not_nil(Maze::Aws::Sam.last_response, 'No lambda response!')

  assert_equal({}, Maze::Aws::Sam.last_response)
end

# Test a Lambda response field equals the given string.
#
# @step_input key_path [String] The response element to test
# @step_input expected [String] The string to test against
Then('the lambda response {string} equals {string}') do |key_path, expected|
  assert_not_nil(Maze::Aws::Sam.last_response, 'No lambda response!')

  actual = Maze::Helper.read_key_path(Maze::Aws::Sam.last_response, key_path)

  assert_equal(expected, actual)
end

# Test a Lambda response field contains the given string.
#
# @step_input key_path [String] The response element to test
# @step_input expected [String] The string to test against
Then('the lambda response {string} contains {string}') do |key_path, expected|
  assert_not_nil(Maze::Aws::Sam.last_response, 'No lambda response!')

  actual = Maze::Helper.read_key_path(Maze::Aws::Sam.last_response, key_path)

  assert_includes(actual, expected)
end

# Test a Lambda response field equals the given integer.
#
# @step_input key_path [String] The response element to test
# @step_input expected [Integer] The integer to test against
Then('the lambda response {string} equals {int}') do |key_path, expected|
  assert_not_nil(Maze::Aws::Sam.last_response, 'No lambda response!')

  actual = Maze::Helper.read_key_path(Maze::Aws::Sam.last_response, key_path)

  assert_equal(expected, actual)
end

# Test a Lambda response field is true.
#
# @step_input key_path [String] The response element to test
Then('the lambda response {string} is true') do |key_path|
  assert_not_nil(Maze::Aws::Sam.last_response, 'No lambda response!')

  actual = Maze::Helper.read_key_path(Maze::Aws::Sam.last_response, key_path)

  assert_true(actual)
end

# Test a Lambda response field is false.
#
# @step_input key_path [String] The response element to test
Then('the lambda response {string} is false') do |key_path|
  assert_not_nil(Maze::Aws::Sam.last_response, 'No lambda response!')

  actual = Maze::Helper.read_key_path(Maze::Aws::Sam.last_response, key_path)

  assert_false(actual)
end

# Test a Lambda response field is null.
#
# @step_input key_path [String] The response element to test
Then('the lambda response {string} is null') do |key_path|
  assert_not_nil(Maze::Aws::Sam.last_response, 'No lambda response!')

  actual = Maze::Helper.read_key_path(Maze::Aws::Sam.last_response, key_path)

  assert_nil(actual)
end

# Test a Lambda response field is not null.
#
# @step_input key_path [String] The response element to test
Then('the lambda response {string} is not null') do |key_path|
  assert_not_nil(Maze::Aws::Sam.last_response, 'No lambda response!')

  actual = Maze::Helper.read_key_path(Maze::Aws::Sam.last_response, key_path)

  assert_not_nil(actual)
end

# Test a Lambda response field is greater than the given integer.
#
# @step_input key_path [String] The response element to test
# @step_input expected [Integer] The integer to test against
Then('the lambda response {string} is greater than {int}') do |key_path, expected|
  assert_not_nil(Maze::Aws::Sam.last_response, 'No lambda response!')

  actual = Maze::Helper.read_key_path(Maze::Aws::Sam.last_response, key_path)

  assert_operator(actual, :>, expected)
end

# Test a Lambda response field is less than the given integer.
#
# @step_input key_path [String] The response element to test
# @step_input expected [Integer] The integer to test against
Then('the lambda response {string} is less than {int}') do |key_path, expected|
  assert_not_nil(Maze::Aws::Sam.last_response, 'No lambda response!')

  actual = Maze::Helper.read_key_path(Maze::Aws::Sam.last_response, key_path)

  assert_operator(actual, :<, expected)
end

# Test a Lambda response field starts with the given string.
#
# @step_input key_path [String] The response element to test
# @step_input expected [String] The string to test against
Then('the lambda response {string} starts with {string}') do |key_path, expected|
  assert_not_nil(Maze::Aws::Sam.last_response, 'No lambda response!')

  actual = Maze::Helper.read_key_path(Maze::Aws::Sam.last_response, key_path)

  assert_kind_of(String, actual)
  assert(
    actual.start_with?(expected),
    "Field '#{key_path}' value ('#{actual}') does not start with '#{expected}'"
  )
end

# Test a Lambda response field ends with the given string.
#
# @step_input key_path [String] The response element to test
# @step_input expected [String] The string to test against
Then('the lambda response {string} ends with {string}') do |key_path, expected|
  assert_not_nil(Maze::Aws::Sam.last_response, 'No lambda response!')

  actual = Maze::Helper.read_key_path(Maze::Aws::Sam.last_response, key_path)

  assert_kind_of(String, actual)
  assert(
    actual.end_with?(expected),
    "Field '#{key_path}' value ('#{actual}') does not start with '#{expected}'"
  )
end

# Test a Lambda response field is an array with a specific number of elements.
#
# @step_input key_path [String] The response element to test
# @step_input expected [Integer] The expected number of elements
Then('the lambda response {string} is an array with {int} element(s)') do |key_path, expected|
  assert_not_nil(Maze::Aws::Sam.last_response, 'No lambda response!')

  actual = Maze::Helper.read_key_path(Maze::Aws::Sam.last_response, key_path)

  assert_kind_of(Array, actual)
  assert_equal(expected, actual.length)
end

# Test a Lambda response field is an array with at least 1 element.
#
# @step_input key_path [String] The response element to test
Then('the lambda response {string} is a non-empty array') do |key_path|
  assert_not_nil(Maze::Aws::Sam.last_response, 'No lambda response!')

  actual = Maze::Helper.read_key_path(Maze::Aws::Sam.last_response, key_path)

  assert_kind_of(Array, actual)
  assert_false(actual.empty?)
end

# Test a Lambda response field matches the given regex.
#
# @step_input key_path [String] The response element to test
# @step_input expected [String] The regex to match against
Then('the lambda response {string} matches the regex {string}') do |key_path, regex|
  expected = Regexp.new(regex)
  assert_not_nil(Maze::Aws::Sam.last_response, 'No lambda response!')

  actual = Maze::Helper.read_key_path(Maze::Aws::Sam.last_response, key_path)

  assert_match(expected, actual)
end
