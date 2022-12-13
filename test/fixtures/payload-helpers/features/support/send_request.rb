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
             elsif request_type == 'trace'
               '/traces'
             else
               '/notify'
             end
  request = Net::HTTP::Post.new(endpoint)
  request['Content-Type'] = 'application/json'

  templates = {
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
    'trace' => {
      'headers' => {
        'Bugsnag-Api-Key' => $api_key,
        'Bugsnag-Payload-Version' => '1.0',
        'Bugsnag-Sent-At' => Time.now().iso8601(3)
      },
      'body' => {
        "resourceSpans": [
          {
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

