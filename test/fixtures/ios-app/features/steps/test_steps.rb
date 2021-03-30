When('I run {string}') do |event_type|
  steps %(
    Given the element "scenario_name" is present
    When I send the keys "#{event_type}" to the element "scenario_name"
    And I close the keyboard
    And I click the element "run_scenario"
  )
end

When("I run {string} and relaunch the app") do |event_type|
  steps %Q{
    When I run "#{event_type}"
    And I relaunch the app after a crash
  }
end

When('I clear all persistent data') do
  steps %(
    Given the element "clear_persistent_data" is present
    And I click the element "clear_persistent_data"
  )
end

def click_if_present(element)
  return false unless Maze.driver.wait_for_element(element, 1)

  Maze.driver.click_element(element)
  true
rescue Selenium::WebDriver::Error::NoSuchElementError
  # Ignore - we have seen clicks fail like this despite having just checked for the element's presence
  false
end

When('I close the keyboard') do
  unless Maze.driver.capabilities['platformName'].eql?('Mac')
    click_if_present 'close_keyboard'
  end
end

When('I configure Bugsnag for {string}') do |event_type|
  steps %(
    Given the element "scenario_name" is present
    When I send the keys "#{event_type}" to the element "scenario_name"
    And I close the keyboard
    And I click the element "start_bugsnag"
  )
end

When('I relaunch the app') do
  case Maze.driver.capabilities['platformName']
  when 'Mac'
    app = Maze.driver.capabilities['app']
    system("killall #{app} > /dev/null && sleep 1")
    Maze.driver.get(app)
  else
    Maze.driver.launch_app
  end
end

When("I relaunch the app after a crash") do
  # This step should only be used when the app has crashed, but the notifier needs a little
  # time to write the crash report before being forced to reopen.  From trials, 2s was not enough.
  sleep(5)
  case Maze.driver.capabilities['platformName']
  when 'Mac'
    Maze.driver.get(Maze.driver.capabilities['app'])
  else
    Maze.driver.launch_app
  end
end

def request_matches_row(body, row)
  row.each do |key, expected_value|
    obs_val = Maze::Helper.read_key_path(body, key)
    next if ('null'.eql? expected_value) && obs_val.nil? # Both are null/nil
    next if !obs_val.nil? && (expected_value.to_s.eql? obs_val.to_s) # Values match
    # Match not found - return false
    return false
  end
  # All matched - return true
  true
end

def check_device_model(field, list)
  internal_names = {
    'iPhone 6' => %w[iPhone7,2],
    'iPhone 6 Plus' => %w[iPhone7,1],
    'iPhone 6S' => %w[iPhone8,1],
    'iPhone 7' => %w[iPhone9,1 iPhone9,2 iPhone9,3 iPhone9,4],
    'iPhone 8' => %w[iPhone10,1 iPhone10,4],
    'iPhone 8 Plus' => %w[iPhone10,2 iPhone10,5],
    'iPhone 11' => %w[iPhone12,1],
    'iPhone 11 Pro' => %w[iPhone12,3],
    'iPhone 11 Pro Max' => %w[iPhone12,5],
    'iPhone X' => %w[iPhone10,3 iPhone10,6],
    'iPhone XR' => %w[iPhone11,8],
    'iPhone XS' => %w[iPhone11,2 iPhone11,4 iPhone11,8]
  }
  expected_model = Maze.config.capabilities['device']
  valid_models = internal_names[expected_model]
  device_model = Maze::Helper.read_key_path(list.current[:body], field)
  assert_true(valid_models != nil ? valid_models.include?(device_model) : true, "The field #{device_model} did not match any of the list of expected fields")
end

Then('the error is valid for the error reporting API') do
  case Maze.driver.capabilities['platformName']
  when 'iOS'
    steps %(
      Then the error is valid for the error reporting API version "4.0" for the "iOS Bugsnag Notifier" notifier
    )
  when 'Mac'
    steps %(
      Then the error is valid for the error reporting API version "4.0" for the "OSX Bugsnag Notifier" notifier
    )
  else
    raise 'Unknown platformName'
  end
end

def wait_for_true
  max_attempts = 300
  attempts = 0
  assertion_passed = false
  until (attempts >= max_attempts) || assertion_passed
    attempts += 1
    assertion_passed = yield
    sleep 0.1
  end
  raise 'Assertion not passed in 30s' unless assertion_passed
end

def send_keys_to_element(element_id, text)
  element = find_element(@element_locator, element_id)
  element.clear()
  element.set_value(text)
end
