When('I send {int} request(s)') do |request_count|
  steps %Q{
    When I set environment variable "REQUEST_COUNT" to "#{request_count}"
    And I run the script "features/scripts/send_counted_requests.rb" using ruby synchronously
  }
end