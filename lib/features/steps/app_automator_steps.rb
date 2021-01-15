# @!group App Automator steps

# Checks a UI element is present
# Requires a running Appium driver
#
# @step_input element_id [String] The locator id
Given('the element {string} is present') do |element_id|
  present = Maze.driver.wait_for_element(element_id)
  assert(present, "The element #{element_id} could not be found")
end

# Checks a UI element is present within a specified number of seconds
# Requires a running Appium driver
#
# @step_input element_id [String] The locator id
# @step_input timeout [Int] The number of seconds to wait before timing out
Given('the element {string} is present within {int} seconds') do |element_id, timeout|
  present = Maze.driver.wait_for_element(element_id, timeout)
  assert(present, "The element #{element_id} could not be found")
end

# Clicks a given element
# Requires a running Appium driver
#
# @step_input element_id [String] The locator id
When('I click the element {string}') do |element_id|
  Maze.driver.click_element(element_id)
rescue StandardError
  # AppiumForMac raises an to run a scenario that crashes the app
  raise unless Maze.config.os == 'macos'

  $logger.warn 'Ignoring exception raised on click_element - this is normal for AppiumForMac if the button click ' \
    'causes the app to crash.'
end

# Sends the app to the background for a number of seconds
# Requires a running Appium driver
#
# @step_input timeout [Integer] The amount of time the app is in the background in seconds
When('I send the app to the background for {int} seconds') do |timeout|
  Maze.driver.background_app(timeout)
end

# Clears a given element
# Requires a running Appium driver
#
# @step_input element_id [String] The locator id
When('I clear the element {string}') do |element_id|
  Maze.driver.clear_element(element_id)
end

# Sends keys to a given element
# Requires a running Appium driver
#
# @step_input keys [String] The keys to send to the element
# @step_input element_id [String] The locator id
When('I send the keys {string} to the element {string}') do |keys, element_id|
  Maze.driver.send_keys_to_element(element_id, keys)
end

# Tests that the given payload value is correct for the target BrowserStack platform.
# This step will assume the expected and payload values are strings.
# If the step is invoked when a remote BrowserStack device is not in use this step will fail.
#
# The DataTable used for this step should have `ios` and `android` in the same row as their expected value:
#   | android | Java.lang.RuntimeException |
#   | ios     | NSException                |
#
# If the expected value is set to "@skip", the check should be skipped.
#
# @step_input field_path [String] The field to test
# @step_input platform_values [DataTable] A table of acceptable values for each platform
Then('the error payload field {string} equals the platform-dependent string:') do |field_path, platform_values|
  test_string_platform_values(field_path, platform_values)
end

# See `the error payload field {string} equals the platform-dependent string:`
#
# @step_input field_path [String] The field to test, prepended with "events.0"
# @step_input platform_values [DataTable] A table of acceptable values for each platform
Then('the event {string} equals the platform-dependent string:') do |field_path, platform_values|
  test_string_platform_values("events.0.#{field_path}", platform_values)
end

# Tests that the given payload value is correct for the target BrowserStack platform.
# This step will assume the expected and payload values are numeric.
# If the step is invoked when a remote BrowserStack device is not in use this step will fail.
#
# The DataTable used for this step should have `ios` and `android` in the same row as their expected value:
#   | android | 1  |
#   | ios     | 5.5 |
#
# If the expected value is set to "@skip", the check should be skipped.
#
# @step_input field_path [String] The field to test
# @step_input platform_values [DataTable] A table of acceptable values for each platform
Then('the error payload field {string} equals the platform-dependent numeric:') do |field_path, platform_values|
  test_numeric_platform_values(field_path, platform_values)
end

# See `the payload field {string} equals the platform-dependent numeric:`
#
# @step_input field_path [String] The field to test, prepended with "events.0"
# @step_input platform_values [DataTable] A table of acceptable values for each platform
Then('the event {string} equals the platform-dependent numeric:') do |field_path, platform_values|
  test_numeric_platform_values("events.0.#{field_path}", platform_values)
end

# Tests that the given payload value is correct for the target BrowserStack platform.
# This step will assume the expected and payload values are booleans.
# If the step is invoked when a remote BrowserStack device is not in use this step will fail.
#
# The DataTable used for this step should have `ios` and `android` in the same row as their expected value:
#   | android | 1 |
#   | ios     | 5 |
#
# If the expected value is set to "@skip", the check should be skipped.
#
# @step_input field_path [String] The field to test
# @step_input platform_values [DataTable] A table of acceptable values for each platform
Then('the error payload field {string} equals the platform-dependent boolean:') do |field_path, platform_values|
  test_boolean_platform_values(field_path, platform_values)
end

# See `the payload field {string} equals the platform-dependent boolean:`
#
# @step_input field_path [String] The field to test, prepended with "events.0"
# @step_input platform_values [DataTable] A table of acceptable values for each platform
Then('the event {string} equals the platform-dependent boolean:') do |field_path, platform_values|
  test_boolean_platform_values("events.0.#{field_path}", platform_values)
end

# See `the payload field {string} equals the platform-dependent string:`
#
# @step_input field_path [String] The field to test, prepended with "events.0.exceptions.0."
# @step_input platform_values [DataTable] A table of acceptable values for each platform
Then('the exception {string} equals the platform-dependent string:') do |field_path, platform_values|
  test_string_platform_values("events.0.exceptions.0.#{field_path}", platform_values)
end

# See `the payload field {string} equals the platform-dependent string:`
#
# @step_input field_path [String] The field to test, prepended with "events.0.exceptions.0.stacktrace.#{num}"
# @step_input field_path [String] The index of the stack frame to test
# @step_input platform_values [DataTable] A table of acceptable values for each platform
Then('the {string} of stack frame {int} equals the platform-dependent string:') do |field_path, num, platform_values|
  test_string_platform_values("events.0.exceptions.0.stacktrace.#{num}.#{field_path}", platform_values)
end

# Sends keys to a given element, clearing it first
# Requires a running Appium driver
#
# @step_input keys [String] The keys to send to the element
# @step_input element_id [String] The locator id
When('I clear and send the keys {string} to the element {string}') do |keys, element_id|
  Maze.driver.clear_and_send_keys_to_element(element_id, keys)
end

def get_expected_platform_value(platform_values)
  raise('This step should only be used when running tests with Appium') if Maze.driver.nil?

  os = Maze.config.capabilities['os']
  expected_value = Hash[platform_values.raw][os]
  raise("There is no expected value for the current platform \"#{os}\"") if expected_value.nil?

  expected_value
end

def should_skip_platform_check(expected_value)
  expected_value.eql?('@skip')
end

def test_string_platform_values(field_path, platform_values)
  expected_value = get_expected_platform_value(platform_values)
  return if should_skip_platform_check(expected_value)

  payload_value = Maze::Helper.read_key_path(Maze::Server.errors.current[:body], field_path)
  assert_equal(expected_value, payload_value)
end

def test_boolean_platform_values(field_path, platform_values)
  expected_value = get_expected_platform_value(platform_values)
  return if should_skip_platform_check(expected_value)

  expected_bool = if expected_value.downcase == 'true'
                    true
                  elsif expected_value.downcase == 'false'
                    false
                  else
                    expected_value
                  end
  payload_value = Maze::Helper.read_key_path(Maze::Server.errors.current[:body], field_path)
  assert_equal(expected_bool, payload_value)
end

def test_numeric_platform_values(field_path, platform_values)
  expected_value = get_expected_platform_value(platform_values)
  return if should_skip_platform_check(expected_value)

  payload_value = Maze::Helper.read_key_path(Maze::Server.errors.current[:body], field_path)
  assert_equal(expected_value.to_f, payload_value)
end
