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
  present = Maze::Api::Appium::UiManager.new.wait_for_element(element_id, timeout)
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

# Touches the screen at the given coordinates
# Requires a running Appium driver
#
# @step_input element_id [String] The locator id
When('I touch the screen at {int},{int}') do |x, y|
  Maze::Api::Appium::UiManager.new.touch_at(x, y)
end

# Touches the screen at the given coordinates a number of times
# Requires a running Appium driver
#
# @step_input element_id [String] The locator id
When('I touch the screen at {int},{int} {int} time(s)') do |x, y, times|
  times.times do
    Maze::Api::Appium::UiManager.new.touch_at(x, y)
    sleep 1
  end
end

# Sends the app to the background indefinitely
# Requires a running Appium driver
When('I send the app to the background') do
  Maze::Api::Appium::AppManager.new.background(-1)
end

# Sends the app to the background for a number of seconds
# Requires a running Appium driver
#
# @step_input timeout [Integer] The amount of time the app is in the background in seconds
When('I send the app to the background for {int} second(s)') do |timeout|
  Maze::Api::Appium::AppManager.new.background(timeout)
end

# Set the device orientation to either portrait or landscape
# Requires a running Appium driver
When('I set the device orientation to {orientation}') do |orientation|
  Maze::Api::Appium::DeviceManager.new.set_rotation orientation
end

