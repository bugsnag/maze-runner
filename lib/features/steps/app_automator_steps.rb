# Checks a UI element is present
#
# @param element_id [String] The locator id
Given("the element {string} is present") do |element_id|
  $driver.wait_for_element(element_id)
end

# Clicks a given element
#
# @param element_id [String] The locator id
When("I click the element {string}") do |element_id|
  $driver.click_element(element_id)
end

# Sends the app to the background for a number of second
#
# @param timeout [Integer] The amount of time the app is in the background
Given("I send the app to the background for {int} seconds") do |timeout|
  $driver.background_app(timeout)
end