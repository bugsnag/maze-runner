#!/usr/bin/env ruby

require 'net/http'
require 'json'
require 'time'

http = Net::HTTP.new('localhost', ENV['MOCK_API_PORT'])
request = Net::HTTP::Post.new('/notify')
request['Content-Type'] = 'application/json'

templates = {
  'no_feature_flags' => {
    'headers' => {},
    'body' => {
      'events' => [
        {},
        {
          'featureFlags' => []
        }
      ]
    }
  },
  'verify_flags' => {
    'headers' => {},
    'body' => {
      'events' => [
        {
          'featureFlags' => [
            {
              'featureFlag' => 'ev_0_flag_var',
              'variant' => 'foo'
            },
            {
              'featureFlag' => 'ev_0_flag_no_var'
            }
          ]
        },
        {
          'featureFlags' => [
            {
              'featureFlag' => 'ev_1_flag_var',
              'variant' => 'bar'
            },
            {
              'featureFlag' => 'ev_1_flag_no_var'
            }
          ]
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
