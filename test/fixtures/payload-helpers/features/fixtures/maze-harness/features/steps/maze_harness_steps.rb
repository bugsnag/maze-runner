When(/^I send an? "(.+)" trace request$/) do |request_type|
  steps %Q{
    When I set environment variable "request_type" to "#{request_type}"
    And I set environment variable "MOCK_API_PORT" to "9349"
    And I run the script "features/scripts/send_trace.sh" synchronously
  }
end


When('I send a span request with {int} span(s)') do |span_count|
  steps %Q{
    When I set environment variable "SPAN_COUNT" to "#{span_count}"
    And I set environment variable "TEST_API_KEY" to "#{$api_key}"
    And I set environment variable "MOCK_API_PORT" to "9349"
    And I run the script "features/scripts/send_spans.sh" synchronously
  }
end