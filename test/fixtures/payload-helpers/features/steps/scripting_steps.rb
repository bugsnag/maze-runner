When(/^I send an? "(.+)"-type request$/) do |request_type|
  $http_response = send_request request_type
end

When(/^I send an? "(.+)" trace request$/) do |request_type|
  steps %Q{
    When I set environment variable "request_type" to "#{request_type}"
    And I set environment variable "MOCK_API_PORT" to "9339"
    And I run the script "features/scripts/send_trace.sh" synchronously
  }
end

When(/^I send an? "(.+)" feature-flag request$/) do |request_type|
  steps %Q{
    When I set environment variable "request_type" to "#{request_type}"
    And I set environment variable "MOCK_API_PORT" to "9339"
    And I run the script "features/scripts/send_feature_flags.sh" synchronously
  }
end

When('I send a span request with {int} span(s)') do |span_count|
  steps %Q{
    When I set environment variable "SPAN_COUNT" to "#{span_count}"
    And I set environment variable "TEST_API_KEY" to "#{$api_key}"
    And I set environment variable "MOCK_API_PORT" to "9339"
    And I run the script "features/scripts/send_spans.sh" synchronously
  }
end

When('The HTTP response header {string} equals {string}') do |header, value|
  Maze.check.equal value, $http_response[header]
end

When('The HTTP response header {string} is null') do |header|
  Maze.check.false($http_response.key?(header))
end

When('I set up the maze-harness console') do
  steps %{
    Given I start a new shell
    And I input "cd features/fixtures/maze-harness" interactively
    And I input "bundle install" interactively
    And I wait for the shell to output a match for the regex "Bundle complete!" to stdout
  }
end
