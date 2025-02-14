# frozen_string_literal: true

require 'date'
require 'net/http'

http = Net::HTTP.new('localhost', '9339')
first_request = Net::HTTP::Post.new('/notify')
first_request['Content-Type'] = 'application/json'
first_request.body = '{"req": "first!"}'
http.request(first_request)

second_request = Net::HTTP::Post.new('/notify')
second_request['Content-Type'] = 'application/json'
second_request.body = %({what bad form})
http.request(second_request)
