require 'net/http'

When("I configure the bugsnag notify endpoint") do
  steps %Q{
    When I set environment variable "BUGSNAG_NOTIFY_ENDPOINT" to "http://#{current_ip}:#{MOCK_API_PORT}"
  }
end

When("I configure the bugsnag sessions endpoint") do
  steps %Q{
    When I set environment variable "BUGSNAG_SESSIONS_ENDPOINT" to "http://#{current_ip}:#{MOCK_API_PORT}"
  }
end

Then("the request used the Node notifier") do
  steps %Q{
    Then the payload field "notifier.name" equals "Bugsnag Node"
    And the payload field "notifier.url" equals "https://github.com/bugsnag/bugsnag-js"
  }
end