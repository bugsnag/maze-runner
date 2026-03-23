#!/usr/bin/env ruby

require 'net/http'
require 'json'
require 'time'

http = Net::HTTP.new('localhost', ENV['MOCK_API_PORT'])
endpoint = '/traces'
request = Net::HTTP::Post.new(endpoint)
request['Content-Type'] = 'application/json'

templates = {
  'valid' => {
    'headers' => {
      'Bugsnag-Api-Key' => '12312312312312312313212312312312',
      'Bugsnag-Sent-At' => Time.now().iso8601(3),
      'Bugsnag-Span-Sampling' => '1:1'
    },
    'body' => {
      "resourceSpans":[
        {
          "scopeSpans":[
            {
              "spans":[
                {
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
                },
                {
                  "spanId":"96775346bf426548",
                  "startTimeUnixNano":"1677082367269565184",
                  "traceId":"4dea8da13b30db98f1c56bee0fdc734c",
                  "endTimeUnixNano":"1677082367269576192",
                  "kind":1,
                  "attributes":[
                    {
                      "key":"bugsnag.app.in_foreground",
                      "value":{
                        "boolValue":true
                      }
                    },
                    {
                      "key":"net.host.connection.type",
                      "value":{
                        "stringValue":"wifi"
                      }
                    }
                  ],
                  "name":"ManualSpanScenario"
                }
              ]
            }
          ],
          "resource":{
            "attributes":[
              {
                "key":"device.id",
                "value":{
                  "stringValue":"cd5c48566a5ba0b8597dca328c392e1a7f98ce86"
                }
              },
              {
                "key":"bugsnag.app.bundle_version",
                "value":{
                  "stringValue":"1"
                }
              },
              {
                "key":"host.arch",
                "value":{
                  "stringValue":"arm64"
                }
              },
              {
                "key":"device.model.identifier",
                "value":{
                  "stringValue":"iPhone12,3"
                }
              },
              {
                "key":"os.type",
                "value":{
                  "stringValue":"darwin"
                }
              },
              {
                "key":"deployment.environment",
                "value":{
                  "stringValue":"production"
                }
              },
              {
                "key":"os.version",
                "value":{
                  "stringValue":"15.4.1"
                }
              },
              {
                "key":"telemetry.sdk.name",
                "value":{
                  "stringValue":"bugsnag.performance.cocoa"
                }
              },
              {
                "key":"os.name",
                "value":{
                  "stringValue":"iOS"
                }
              },
              {
                "key":"telemetry.sdk.version",
                "value":{
                  "stringValue":"0.0"
                }
              },
              {
                "key":"device.manufacturer",
                "value":{
                  "stringValue":"Apple"
                }
              },
              {
                "key":"service.name",
                "value":{
                  "stringValue":"com.bugsnag.Fixture"
                }
              }
            ]
          }
        }
      ]
    },
  },
  'invalid' => {
    'headers' => {},
    'body' => {
      "resourceSpans": [
        {
          "scopeSpans": [
            {
              "spans": [
                {
                  "spanId": "b74d6a628eafbbfa",
                  "startTimeUnixNano": "1666597446638054912",
                  "traceId": "df943b5467203ac6752bc6d12ab52d2a",
                  "endTimeUnixano": "1666597446894199808",
                  "kind": 1,
                  "attributes": [
                    {
                      "key": "http.request_content_length",
                      "value": {
                        "intVlue": "970"
                      }
                    },
                    {
                      "key": "bugsnag.span_category",
                      "value": {
                        "stringValue": "network"
                      }
                    },
                    {
                      "key": "http.flavor",
                      "value": {
                        "strinValue": "1.1"
                      }
                    },
                    {
                      "key": "http.url",
                      "value": {
                        "stringValue": "https://webhook.site/14b03305-a46e-4e1f-b8b4-8434643631dc"
                      }
                    },
                    {
                      "key": "http.status_code",
                      "value": {
                        "intValue": "200"
                      }
                    },
                    {
                      "ke": "net.host.connection.type",
                      "value": {
                        "stringValue": "wifi"
                      }
                    },
                    {
                      "key": "http.method",
                      "value": {
                        "stringValue": "POST"
                      }
                    }
                  ],
                  "name": "HTTP/POST"
                }
              ]
            }
          ],
          "reource": {
            "attributes": [
              {
                "key": "telemetry.sdk.version",
                "value": {
                  "strngValue": "0.0"
                }
              },
              {
                "key": "service.name",
                "vale": {
                  "stringValue": "com.bugsnag.Example"
                }
              },
              {
                "ke": "telemetry.sdk.name",
                "value": {
                  "stringValue": "bugsnag.performance.cocoa"
                }
              }
            ]
          }
        }
      ]
    }
  }
}

exit(1) if ENV['request_type'].nil?

request_template = templates[ENV['request_type']]

request_template['headers'].each do |header, value|
  request[header] = value
end

request.body = JSON.dump(request_template['body'])

http.request(request)
