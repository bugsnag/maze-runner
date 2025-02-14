require 'net/http'
require 'json'
require 'time'

When('I send a request to the {string} endpoint') do |endpoint|
  http = Net::HTTP.new('localhost', 9349)
  request = Net::HTTP::Post.new("/#{endpoint}")
  request['Content-Type'] = 'application/json'

  payload = {
    'headers' => {
      'Bugsnag-Api-Key' => ENV['TEST_API_KEY'],
      'Bugsnag-Payload-Version' => '1.0'
    },
    'body' => {
      'number' => 120,
      'string' => 'foobar',
      'array' => [1, 2, 3],
      'hash' => {
        'val1' => 1,
        'val2' => 2
      }
    }
  }

  payload['headers'].each do |header, value|
    request[header] = value
  end

  request.body = JSON.dump(payload['body'])

  http.request(request)
end
