#!/usr/bin/env ruby

require 'net/http'
require 'json'
require 'time'
require 'zlib'

http = Net::HTTP.new('localhost', ENV['MOCK_API_PORT'])
request = Net::HTTP::Post.new('/traces')
request['Content-Type'] = 'application/json'

start_time = Time.now.to_i * 1000 * 1000 * 1000
end_time = start_time + (2 * 1000 * 1000 * 1000)

payload = {
  'headers' => {
    'Bugsnag-Api-Key' => ENV['TEST_API_KEY'],
    'Bugsnag-Payload-Version' => '1.0',
    'Bugsnag-Span-Sampling' => '1:1',
    'Bugsnag-Sent-At' => Time.now().iso8601(3),
    'Bugsnag-Integrity' => 'sha1 bd1cbbd2ab9b05a96cbb83a6bcac829ff255a9fe'
  },
  'body' => {
    'resourceSpans' => [
      {
        'scopeSpans' => [
          {
            'spans' => [
                {
                    "spanId":"7af51275a21aa300",
                    "startTimeUnixNano": "#{start_time}",
                    "traceId":"f8b18e12a2c1dca33362ac31772ed3b4",
                    "endTimeUnixNano": "#{end_time}",
                    "kind":1,
                    "attributes":[
                        {
                        "key":"bugsnag.sampling.p",
                        "value":{
                            "doubleValue":1
                        }
                        },
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
            ]
          }
        ],
        'resource' => {
          'attributes' => [
            {
              "key":"service.version",
              "value":{
                "stringValue":"1.0.0"
              }
            },
            {
              "key":"device.id",
              "value":{
                "stringValue":"cd5c48566a5ba0b8597dca328c392e1a7f98ce86"
              }
            },
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

compressed_body = Zlib::GzipWriter.new(StringIO.new).write(JSON.dump(payload['body'])).close

payload['headers'].each do |header, value|
  request[header] = value
end

request.body = compressed_body.string

http.request(request)
