#!/usr/bin/env ruby

require 'net/http'
require 'json'
require 'time'

http = Net::HTTP.new('localhost', ENV['MOCK_API_PORT'])
request = Net::HTTP::Post.new('/traces')
request['Content-Type'] = 'application/json'

sample_span = {
  "spanId":"7af51275a21aa300",
  "startTimeUnixNano":"1677082365052111104",
  "traceId":"f8b18e12a2c1dca33362ac31772ed3b4",
  "endTimeUnixNano":"1677082367268691968",
  "kind":1,
  "attributes":[
    {
      "key":"bugsnag.app_start.type",
      "value":{
        "stringValue":"cold"
      }
    },
    {
      "key":"bugsnag.span.category",
      "value":{
        "stringValue":"app_start"
      }
    },
    {
      "key":"net.host.connection.type",
      "value":{
        "stringValue":"wifi"
      }
    },
    {
      "key":"bugsnag.app.in_foreground",
      "value":{
        "boolValue":true
      }
    }
  ],
  "name":"AppStart\\134/Cold"
}

span_count = ENV['SPAN_COUNT']

payload = {
  'headers' => {
    'Bugsnag-Api-Key' => ENV['TEST_API_KEY'],
    'Bugsnag-Payload-Version' => '1.0',
    'Bugsnag-Span-Sampling' => '1:1',
    'Bugsnag-Sent-At' => Time.now().iso8601(3)
  },
  'body' => {
    'resourceSpans' => [
      {
        'scopeSpans' => [
          {
            'spans' => (1..span_count.to_i).map {|_i| sample_span}
          }
        ],
        'resource' => {
          'attributes' => [
            {
              "key":"telemetry.sdk.name",
              "value":{
                "stringValue":"bugsnag.performance.cocoa"
              }
            },
            {
              "key":"deployment.environment",
              "value":{
                "stringValue":"production"
              }
            },
            {
              "key":"telemetry.sdk.version",
              "value":{
                "stringValue":"0.0"
              }
            }
          ]
        }
      }
    ]
  }
}

payload['headers'].each do |header, value|
  request[header] = value
end

request.body = JSON.dump(payload['body'])

http.request(request)
