# frozen_string_literal: true

require 'date'
require 'net/http'

request_count = ENV['REQUEST_COUNT']
http = Net::HTTP.new('localhost', '9339')
(1..request_count).each do |i|
  request = Net::HTTP::Post.new('/notify')
  request['Content-Type'] = 'application/json'
  request.body = "{\"count\":#{i}}"
  http.request(request)
end
