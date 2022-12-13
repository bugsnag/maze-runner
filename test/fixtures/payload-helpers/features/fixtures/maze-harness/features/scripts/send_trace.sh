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
                  "endTimeUnixNano": "1666597446894199808",
                  "kind": "SPAN_KIND_INTERNAL",
                  "attributes": [
                    {
                      "key": "http.request_content_length",
                      "value": {
                        "intValue": "970"
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
                        "stringValue": "1.1"
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
                      "key": "net.host.connection.type",
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
          "resource": {
            "attributes": [
              {
                "key": "telemetry.sdk.version",
                "value": {
                  "stringValue": "0.0"
                }
              },
              {
                "key": "service.name",
                "value": {
                  "stringValue": "com.bugsnag.Example"
                }
              },
              {
                "key": "telemetry.sdk.name",
                "value": {
                  "stringValue": "bugsnag.performance.cocoa"
                }
              }
            ]
          }
        }
      ]
    }
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
                  "kind": "SPAN_KIND_INTERNAL",
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
