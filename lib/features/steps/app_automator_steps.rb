# @!group App Automator steps

# Checks a UI element is present
# Requires a running Appium driver
#
# @step_input element_id [String] The locator id
Given('the element {string} is present') do |element_id|
  present = Maze::Api::Appium::UiManager.new.wait_for_element(element_id)
  raise Maze::Error::AppiumElementNotFoundError.new("The element #{element_id} could not be found", element_id) unless present
end

# Checks a UI element is present within a specified number of seconds
# Requires a running Appium driver
#
# @step_input element_id [String] The locator id
# @step_input timeout [Int] The number of seconds to wait before timing out
Given('the element {string} is present within {int} seconds') do |element_id, timeout|
  present = Maze.driver.wait_for_element(element_id, timeout)
  raise Maze::Error::AppiumElementNotFoundError.new("The element #{element_id} could not be found", element_id) unless present
end

# Clicks a given element
# Requires a running Appium driver
#
# @step_input element_id [String] The locator id
When('I click the element {string}') do |element_id|
  Maze::Api::Appium::UiManager.new.click_element(element_id)
end

# Clicks a given element if present
# Requires a running Appium driver
#
# @step_input element_id [String] The locator id
When('I click the element {string} if present') do |element_id|
  Maze::Api::Appium::UiManager.new.click_element_if_present(element_id)
end

# Sends the app to the background indefinitely
# Requires a running Appium driver
When('I send the app to the background') do
  Maze.driver.background_app(-1)
end

# Sends the app to the background for a number of seconds
# Requires a running Appium driver
#
# @step_input timeout [Integer] The amount of time the app is in the background in seconds
When('I send the app to the background for {int} second(s)') do |timeout|
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

# Set the device orientation to either portrait or landscape
# Requires a running Appium driver
When('I set the device orientation to {orientation}') do |orientation|
  Maze.driver.set_rotation orientation
end

# Sends keys to a given element, clearing it first
# Requires a running Appium driver
#
# @step_input keys [String] The keys to send to the element
# @step_input element_id [String] The locator id
When('I clear and send the keys {string} to the element {string}') do |keys, element_id|
  Maze.driver.clear_and_send_keys_to_element(element_id, keys)
end

