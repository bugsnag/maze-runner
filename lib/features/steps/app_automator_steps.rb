# @!group App Automator steps

# Checks a UI element is present
# Requires a running Appium driver
#
# @step_input element_id [String] The locator id
Given("the element {string} is present") do |element_id|
  present = $driver.wait_for_element(element_id)
  assert(present, "The element #{element_id} could not be found")
end

# Clicks a given element
# Requires a running Appium driver
#
# @step_input element_id [String] The locator id
When("I click the element {string}") do |element_id|
  $driver.click_element(element_id)
end

# Sends the app to the background for a number of seconds
# Requires a running Appium driver
#
# @step_input timeout [Integer] The amount of time the app is in the background in seconds
When("I send the app to the background for {int} seconds") do |timeout|
  $driver.background_app(timeout)
end

# Clears a given element
# Requires a running Appium driver
#
# @step_input element_id [String] The locator id
When("I clear the element {string}") do |element_id|
  $driver.clear(element_id, keys)
end

# Sends keys to a given element
# Requires a running Appium driver
#
# @step_input keys [String] The keys to send to the element
# @step_input element_id [String] The locator id
When("I send the keys {string} to the element {string}") do |keys, element_id|
  $driver.send_keys_to_element(element_id, keys)
end

# Sends keys to a given element, clearing it first
# Requires a running Appium driver
#
# @step_input keys [String] The keys to send to the element
# @step_input element_id [String] The locator id
When("I clear and send the keys {string} to the element {string}") do |keys, element_id|
  $driver.clear_and_send_keys_to_element(element_id, keys)
end
