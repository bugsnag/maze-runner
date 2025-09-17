When("I request a(n) {string} type error config and store the response") do |request_type|
  $error_config = get_error_config(request_type)
end

When(/^I make an? "(.+)"-type POST request$/) do |request_type|
  steps %(
    When I set environment variable "request_type" to "#{request_type}"
    And I set environment variable "MOCK_API_PORT" to "9339"
    And I run the script "features/scripts/post_request.rb" using ruby synchronously
  )
end

Then('the requests match the following:') do |data_table|
  requests = Maze::Server.errors.all
  Maze::Assertions::RequestSetAssertions.assert_requests_match requests, data_table
end


Then('the stored error config body matches the contents of {string}') do |filename|
  Maze.check.equal(File.read(filename), $error_config.body)
end

Then('the stored error config status code equals {string}') do |status|
  Maze.check.equal(status, $error_config.code)
end

Then('the stored error config {string} header equals {string}') do |key, value|
  Maze.check.equal(value, $error_config[key])
end
