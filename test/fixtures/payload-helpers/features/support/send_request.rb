#!/usr/bin/env ruby

require 'net/http'
require 'json'
require 'time'

def send_request(request_type, mock_api_port = 9339)
  http = Net::HTTP.new('localhost', mock_api_port)
  endpoint = if request_type == 'session'
               '/sessions'
             elsif request_type == 'build'
               '/builds'
             elsif request_type.start_with? 'metric'
               '/metrics'
             elsif request_type == 'trace' || request_type == 'browser-trace' || request_type == 'sampling-trace'
               '/traces'
             else
               '/notify'
             end
  request = Net::HTTP::Post.new(endpoint)
  request['Content-Type'] = 'application/json'

  start_time = Time.now.to_i * 1000 * 1000 * 1000
  end_time = start_time + (2 * 1000 * 1000 * 1000)

  templates = {
    'metric-age' => {
      'headers' => {},
      'body' => {
        'name' => 'steve',
        'age' => '44',
      }
    },
    'metric-shoeSize' => {
      'headers' => {},
      'body' => {
        'name' => 'steve',
        'shoeSize' => '14',
      }
    },
    'payload' => {
      'headers' => {
        'Bugsnag-Api-Key' => $api_key,
        'Bugsnag-Payload-Version' => '4.0',
        'Bugsnag-Sent-At' => Time.now().iso8601(3)
      },
      'body' => {
        'apiKey' => $api_key,
        'payloadVersion' => '4.0',
        'notifier' => {
          'name' => 'Maze-runner',
          'url' => 'not null',
          'version' => '4.4.4'
        },
        'events' => [
          {
            'severity' => 'bad',
            'severityReason' => {
              'type' => 'very bad'
            },
            'unhandled' => true,
            'exceptions' => []
          }
        ]
      }
    },
    'session' => {
      'headers' => {
        'Bugsnag-Api-Key' => $api_key,
        'Bugsnag-Payload-Version' => '1.0',
        'Bugsnag-Sent-At' => Time.now().iso8601(3)
      },
      'body' => {
        'notifier' => {
          'name' => 'Maze-runner',
          'url' => 'not null',
          'version' => '4.4.4'
        },
        'app' => 'not null',
        'device' => 'not null'
      }
    },
    'sampling-trace' => {
      'headers' => {
        'Bugsnag-Api-Key' => $api_key,
        'Bugsnag-Payload-Version' => '1.0',
        'Bugsnag-Sent-At' => Time.now().iso8601(3),
        'Bugsnag-Span-Sampling' => '1:1'
      },
      'body' => {
        "resourceSpans": []
      }
    },
    'trace' => {
      'headers' => {
        'Bugsnag-Api-Key' => $api_key,
        'Bugsnag-Payload-Version' => '1.0',
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
                  },
                  {
                    "spanId":"96775346bf426548",
                    "startTimeUnixNano": "#{start_time}",
                    "traceId":"4dea8da13b30db98f1c56bee0fdc734c",
                    "endTimeUnixNano": "#{end_time}",
                    "kind":"SPAN_KIND_INTERNAL",
                    "attributes":[
                      {
                        "key":"bugsnag.sampling.p",
                        "value":{
                          "doubleValue":1
                        }
                      },
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
                  },
                  {
                    "spanId":"96775346a21aa300",
                    "parentSpanId":"96775346bf426548",
                    "startTimeUnixNano": "#{start_time}",
                    "traceId":"4dea8da13b30db98f1c56bee0fdc734c",
                    "endTimeUnixNano": "#{end_time}",
                    "kind":"SPAN_KIND_INTERNAL",
                    "attributes":[
                      {
                        "key":"bugsnag.sampling.p",
                        "value":{
                          "doubleValue":1
                        }
                      },
                      {
                        "key":"test.bool_value",
                        "value":{
                          "boolValue":true
                        }
                      },
                      {
                        "key":"test.string_value",
                        "value":{
                          "stringValue":"frayed_knot"
                        }
                      },
                      {
                        "key":"test.int_value",
                        "value":{
                          "intValue":"50"
                        }
                      },
                      {
                        "key":"test.double_value",
                        "value":{
                          "doubleValue":6.4
                        }
                      },
                      {
                        "key":"test.bytes_value",
                        "value":{
                          "bytesValue":"deadbeef"
                        }
                      }
                    ],
                    "name":"TestSpan"
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
                  "key":"service.version",
                  "value":{
                    "stringValue":"1.0"
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
      }
    },
    'browser-trace' => {
      'headers' => {
        'Bugsnag-Api-Key' => $api_key,
        'Bugsnag-Payload-Version' => '1.0',
        'Bugsnag-Sent-At' => Time.now().iso8601(3),
        'Bugsnag-Span-Sampling' => '1:1'
      },
      'body' => {
        "resourceSpans": [
          {
            "resource": {
              "attributes": [
                {
                  "key": "deployment.environment",
                  "value": {
                    "stringValue": "production"
                  }
                },
                {
                  "key": "telemetry.sdk.name",
                  "value": {
                    "stringValue": "bugsnag.performance.browser"
                  }
                },
                {
                  "key": "telemetry.sdk.version",
                  "value": {
                    "stringValue": "0.0.0"
                  }
                },
                {
                  "key": "userAgent",
                  "value": {
                    "stringValue": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36"
                  }
                },
                {
                  "key": "platform",
                  "value": {
                    "stringValue": "macOS"
                  }
                },
                {
                  "key": "mobile",
                  "value": {
                    "boolValue": false
                  }
                }
              ]
            },
            "scopeSpans": [
              {
                "spans": [
                  {
                    "name": "Custom/ManualSpanScenario",
                    "kind": 3,
                    "spanId": "91d2a550b5f30013",
                    "traceId": "b9aeacea86240cf4c07284e819d39ba8",
                    "startTimeUnixNano": "#{start_time}",
                    "endTimeUnixNano": "#{end_time}",
                    "attributes": [
                      {
                        "key": "browser.page.url",
                        "value": {
                          "stringValue": "http://localhost:9340/manual-span/?ENDPOINT=http://localhost:9339/traces&LOGS=http://localhost:9339/logs&API_KEY=b3ad5c823d527e720d9beb4767efda18"
                        }
                      }
                    ]
                  },
                  {
                    "spanId":"96775346bf426548",
                    "startTimeUnixNano": "#{start_time}",
                    "traceId":"4dea8da13b30db98f1c56bee0fdc734c",
                    "endTimeUnixNano": "#{end_time}",
                    "kind":"SPAN_KIND_INTERNAL",
                    "attributes":[
                      {
                        "key":"test.next_payload_value",
                        "value":{
                          "stringValue":"another!"
                        }
                      }
                    ],
                    "name":"TestSpan"
                  }
                ]
              }
            ]
          }
        ]
      }
    },
    'unhandled' => {
      'headers' => {},
      'body' => {
        'events' => [
          {
            'severity' => 'error',
            'severityReason' => {
              'type' => 'unhandled'
            },
            'unhandled' => true
          }
        ]
      }
    },
    'unhandled-with-session' => {
      'headers' => {},
      'body' => {
        'events' => [
          {
            'severity' => 'error',
            'severityReason' => {
              'type' => 'unhandled'
            },
            'session' => {
              'events' => {
                'unhandled' => 1
              }
            },
            'unhandled' => true
          }
        ]
      }
    },
    'unhandled-with-severity' => {
      'headers' => {},
      'body' => {
        'events' => [
          {
            'severity' => 'info',
            'severityReason' => {
              'type' => 'userSpecifiedSeverity'
            },
            'unhandled' => true
          }
        ]
      }
    },
    'handled' => {
      'headers' => {},
      'body' => {
        'events' => [
          {
            'severity' => 'warning',
            'severityReason' => {
              'type' => 'handled'
            },
            'unhandled' => false
          }
        ]
      }
    },
    'handled-with-session' => {
      'headers' => {},
      'body' => {
        'events' => [
          {
            'severity' => 'warning',
            'severityReason' => {
              'type' => 'handled'
            },
            'session' => {
              'events' => {
                'handled' => 1
              }
            },
            'unhandled' => false
          }
        ]
      }
    },
    'handled-with-severity' => {
      'headers' => {},
      'body' => {
        'events' => [
          {
            'severity' => 'error',
            'severityReason' => {
              'type' => 'userSpecifiedSeverity'
            },
            'unhandled' => false
          }
        ]
      }
    },
    'handled-then-unhandled' => {
      'headers' => {},
      'body' => {
        'events' => [
          {
            'severity' => 'warning',
            'severityReason' => {
              'type' => 'handled'
            },
            'session' => {
              'events' => {
                'handled' => 1,
                'unhandled' => 0
              }
            },
            'unhandled' => false
          },
          {
            'severity' => 'error',
            'severityReason' => {
              'type' => 'unhandled'
            },
            'session' => {
              'events' => {
                'handled' => 1,
                'unhandled' => 1
              }
            },
            'unhandled' => true
          }
        ]
      }
    },
    'breadcrumb' => {
      'headers' => {},
      'body' => {
        'events' => [
          {
            'breadcrumbs' => [
              {
                'type' => 'process',
                'name' => 'foo',
                'timestamp' => '2019-11-26T10:15:46Z',
              },
            ]
          }
        ]
      }
    },
    'breadcrumbs' => {
      'headers' => {},
      'body' => {
        'events' => [
          {
            'breadcrumbs' => [
              {
                'type' => 'process',
                'name' => 'foo',
                'timestamp' => '2019-11-26T10:15:46Z',
                'metaData' => {
                  'message' => "Foobar"
                }
              },
              {
                'type' => 'process',
                'name' => 'bar',
                'timestamp' => '2019-11-26T10:18:23Z',
                'metaData' => {
                  'a' => 1,
                  'b' => 2,
                  'c' => 3
                }
              },
              {
                'type' => 'testing',
                'name' => 'bar',
                'timestamp' => '2019-11-26T10:18:23Z',
                'metaData' => {
                  'message' => "Barfoo"
                }
              }
            ]
          }
        ]
      }
    },
    'build' => {
      'headers' => {},
      'body' => {
        'apiKey' => $api_key,
        'appVersion' => 'SEBT£',
        'proguard' => 'rutherford',
        'appId' => 'banks',
        'versionCode' => 'ABACAB',
        'buildUUID' => 'gabriel',
        'versionName' => 'collins',
        'genesis' => true,
        'yes' => false,
        'wakeman' => nil,
        'albums' => 15,
        'live_albums' => 6
      }
    }
  }

  request_template = templates[request_type]

  request_template['headers'].each do |header, value|
    request[header] = value
  end

  request.body = JSON.dump(request_template['body'])

  http.request(request)
end

