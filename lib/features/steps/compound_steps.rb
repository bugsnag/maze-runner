When(/^I configure the bugsnag endpoint$/) do
  steps %Q{
    When I set environment variable "BUGSNAG_ENDPOINT" to "http://#{current_ip}:#{MOCK_API_PORT}"
  }
end
When(/^I navigate to the route "(.*)" on port "(\d*)"/) do |route, port|
  steps %Q{
    When I open the URL "http://localhost:#{port}#{route}"
    And I wait for 1 second
  }
end
Then(/^the request used payload v4 headers$/) do
  steps %Q{
    Then the "bugsnag-api-key" header is not null
    And the "bugsnag-payload-version" header equals "4.0"
    And the "bugsnag-sent-at" header is a timestamp
  }
end
Then(/^the request contained the api key "(.*)"$/) do |api_key|
  steps %Q{
    Then the "bugsnag-api-key" header equals "#{api_key}"
    And the payload field "apiKey" equals "#{api_key}"
  }
end
Then(/^the request used the "(.*)" notifier$/) do |notifier_name|
  steps %Q{
    Then the payload field "notifier.name" equals "#{notifier_name}"
    And the payload field "notifier.url" is not null
  }
end
