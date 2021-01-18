# @!group Browser steps

When('I navigate to the URL {string}') do |path|
  $logger.debug "Navigating to: #{path}"
  Maze.driver.navigate.to path
end

Then(/^the error is a valid browser payload for the error reporting API$/) do
  if !/^ie_(8|9|10)$/.match(Maze.config.bs_browser)
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
    And the error payload field "notifier.name" is not null
    And the error payload field "notifier.url" is not null
    And the error payload field "notifier.version" is not null
    And the error payload field "events" is a non-empty array

    And each element in error payload field "events" has "severity"
    And each element in error payload field "events" has "severityReason.type"
    And each element in error payload field "events" has "unhandled"
    And each element in error payload field "events" has "exceptions"

    And the exception "type" equals "browserjs"
  )
end

Then('the session is a valid browser payload for the session tracking API') do
  if !/^ie_(8|9|10)$/.match(Maze.config.bs_browser)
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
  if Maze.driver.local_storage?
    step('the event "device.id" matches "^c[a-z0-9]{20,32}$"')
  else
    $logger.info('Local storage is not supported in this browser, assuming device ID is null')
    step('the event "device.id" is null')
  end
end

Then('the event device ID is {string}') do |expected_id|
  if Maze.driver.local_storage?
    step("the event \"device.id\" equals \"#{expected_id}\"")
  else
    $logger.info('Local storage is not supported in this browser, assuming device ID is null')
    step('the event "device.id" is null')
  end
end

# @!endgroup
