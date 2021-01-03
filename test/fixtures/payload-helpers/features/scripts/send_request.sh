#!/usr/bin/env ruby

require 'net/http'
require 'json'
require 'time'

http = Net::HTTP.new('localhost', ENV['MOCK_API_PORT'])
endpoint = if ENV['request_type'] == 'session'
             '/sessions'
           else
             '/notify'
           end
request = Net::HTTP::Post.new(endpoint)
request['Content-Type'] = 'application/json'

templates = {
  'payload' => {
    'headers' => {
      'Bugsnag-Api-Key' => ENV['BUGSNAG_API_KEY'],
      'Bugsnag-Payload-Version' => '4.0',
      'Bugsnag-Sent-At' => Time.now().iso8601(3)
    },
    'body' => {
      'apiKey' => ENV['BUGSNAG_API_KEY'],
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
      'Bugsnag-Api-Key' => ENV['BUGSNAG_API_KEY'],
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
            }
          ]
        }
      ]
    }
  },
}

exit(1) if ENV['request_type'].nil?

request_template = templates[ENV['request_type']]

request_template['headers'].each do |header, value|
  request[header] = value
end

request.body = JSON.dump(request_template['body'])

http.request(request)
