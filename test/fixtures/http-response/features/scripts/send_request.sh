#!/usr/bin/env ruby

require 'net/http'

http = Net::HTTP.new('localhost', '9339')
first_request = Net::HTTP::Post.new('/notify')
first_request['Content-Type'] = 'application/json'
first_request.body = '{"req": "first!"}'

first_response = http.request(first_request)

second_request = Net::HTTP::Post.new('/notify')
second_request['Content-Type'] = 'application/json'

second_request.body = "{\"first_code\": \"#{first_response.code}\"}"

second_response = http.request(second_request)

third_request = Net::HTTP::Post.new('/notify')
third_request['Content-Type'] = 'application/json'

third_request.body = "{\"second_code\": \"#{second_response.code}\"}"

http.request(third_request)
