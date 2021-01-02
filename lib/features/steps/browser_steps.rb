# @!group Browser steps

When('I navigate to the URL {string}') do |path|
  $logger.debug "Navigating to: #{path}"
  MazeRunner.driver.navigate.to path
end

When('the test should run in this browser') do
  wait = Selenium::WebDriver::Wait.new(timeout: 10)
  wait.until {
    MazeRunner.driver.find_element(id: 'bugsnag-test-should-run') &&
    MazeRunner.driver.find_element(id: 'bugsnag-test-should-run').text != 'PENDING'
  }
  skip_this_scenario if MazeRunner.driver.find_element(id: 'bugsnag-test-should-run').text == 'NO'
end

When('I let the test page run for up to {int} seconds') do |n|
  wait = Selenium::WebDriver::Wait.new(timeout: n)
  wait.until {
    MazeRunner.driver.find_element(id: 'bugsnag-test-state') &&
    (
      MazeRunner.driver.find_element(id: 'bugsnag-test-state').text == 'DONE' ||
      MazeRunner.driver.find_element(id: 'bugsnag-test-state').text == 'ERROR'
    )
  }
  txt = MazeRunner.driver.find_element(id: 'bugsnag-test-state').text
  assert_equal('DONE', txt, "Expected #bugsnag-test-state text to be 'DONE'. It was '#{txt}'.")
end

Then(/^the request is a valid browser payload for the error reporting API$/) do
  if !/^ie_(8|9|10)$/.match(MazeRunner.config.bs_browser)
    steps %(
      Then the error "Bugsnag-API-Key" header is not null
      And the error "Content-Type" header equals one of:
        | application/json |
        | application/json; charset=UTF-8 |
      And the error "Bugsnag-Payload-Version" header equals "4"
      And the error "Bugsnag-Sent-At" header is a timestamp
    )
  else
    steps %(
      Then the error "apiKey" query parameter is not null
      And the error "payloadVersion" query parameter equals "4"
      And the error "sentAt" query parameter is a timestamp
    )
  end
  steps %(
    And the payload field "notifier.name" is not null
    And the payload field "notifier.url" is not null
    And the payload field "notifier.version" is not null
    And the payload field "events" is a non-empty array

    And each element in payload field "events" has "severity"
    And each element in payload field "events" has "severityReason.type"
    And each element in payload field "events" has "unhandled"
    And each element in payload field "events" has "exceptions"

    And the exception "type" equals "browserjs"
  )
end

Then('the request is a valid browser payload for the session tracking API') do
  if !/^ie_(8|9|10)$/.match(MazeRunner.config.bs_browser)
    steps %(
      Then the session "Bugsnag-API-Key" header is not null
      And the session "Content-Type" header equals one of:
        | application/json |
        | application/json; charset=UTF-8 |
      And the session "Bugsnag-Payload-Version" header equals "1"
      And the session "Bugsnag-Sent-At" header is a timestamp
    )
  else
    steps %(
      Then the session "apiKey" query parameter is not null
      And the session "payloadVersion" query parameter equals "1"
      And the session "sentAt" query parameter is a timestamp
    )
  end
  steps %(
    And the session payload field "app" is not null
    And the session payload field "device" is not null
    And the session payload field "notifier.name" is not null
    And the session payload field "notifier.url" is not null
    And the session payload field "notifier.version" is not null
    And the session payload has a valid sessions array
  )
end

Then('the event device ID is valid') do
  if MazeRunner.driver.local_storage?
    step('the event "device.id" matches "^c[a-z0-9]{20,32}$"')
  else
    $logger.info('Local storage is not supported in this browser, assuming device ID is null')
    step('the event "device.id" is null')
  end
end

Then('the event device ID is {string}') do |expected_id|
  if MazeRunner.driver.local_storage?
    step("the event \"device.id\" equals \"#{expected_id}\"")
  else
    $logger.info('Local storage is not supported in this browser, assuming device ID is null')
    step('the event "device.id" is null')
  end
end
