require 'net/http'

When('I start a timer') do
  $timer_start = Time.now.to_f
end

Then('at least {int} ms have passed') do |millis|
  duration = (Time.now.to_f - $timer_start) * 1000
  assert_compare millis, '<', duration
end

When('I make a reflective {word} request with status {string} and delay of {string}') do |method, status, delay_ms|
  http = Net::HTTP.new('localhost', '9340')

  case method.downcase
  when 'get'
    request = Net::HTTP::Get.new("/reflect?status=#{status}&delay_ms=#{delay_ms}")
  when 'post'
    request = Net::HTTP::Post.new('/reflect')
    request['Content-Type'] = 'application/json'
    request.body = "{\"status\": \"#{status}\", \"delay_ms\": \"#{delay_ms}\"}"
  end

  response = http.request(request)
  $response_code = response.code
end

Then('the status code for the last reflective request was {string}') do |status|
  assert_equal status, $response_code
end
