When(/^I send an? "(.+)"-type request$/) do |request_type|
  $http_response = send_request request_type
end

When(/^I send an? "(.+)" feature-flag request$/) do |request_type|
  steps %Q{
    When I set environment variable "request_type" to "#{request_type}"
    And I set environment variable "MOCK_API_PORT" to "9339"
    And I run the script "features/scripts/send_feature_flags.sh" synchronously
  }
end

When('The HTTP response header {string} equals {string}') do |header, value|
  Maze.check.equal value, $http_response[header]
end

When('The HTTP response header {string} is null') do |header|
  Maze.check.nil $http_response[header]
end
