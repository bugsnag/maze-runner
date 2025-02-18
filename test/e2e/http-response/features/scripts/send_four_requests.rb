# frozen_string_literal: true

require 'date'
require 'net/http'

# 1st
http = Net::HTTP.new('localhost', '9339')
first_request = Net::HTTP::Post.new('/notify')
first_request['Content-Type'] = 'application/json'
first_request.body = '{"req": "first!"}'

first_response = http.request(first_request)

# 2nd
second_request = Net::HTTP::Post.new('/notify')
second_request['Content-Type'] = 'application/json'
second_request.body = %({
  "first_code": "#{first_response.code}"
})

second_response = http.request(second_request)

# 3rd
third_request = Net::HTTP::Post.new('/notify')
third_request['Content-Type'] = 'application/json'
third_request.body = %({
  "second_code": "#{second_response.code}"
})

third_response = http.request(third_request)

# 4th
fourth_request = Net::HTTP::Post.new('/notify')
fourth_request['Content-Type'] = 'application/json'
fourth_request.body = %({
  "third_code": "#{third_response.code}"
})

http.request(fourth_request)
