# frozen_string_literal: true

require 'date'
require 'net/http'

http = Net::HTTP.new('localhost', '9339')

first_options_request = Net::HTTP::Options.new('/notify')
first_options_response = http.request(first_options_request)

first_post_request = Net::HTTP::Post.new('/notify')
first_post_request['Content-Type'] = 'application/json'

first_post_request.body = %({
  "first_options_code": "#{first_options_response.code}"
})

first_post_response = http.request(first_post_request)

second_options_request = Net::HTTP::Options.new('/notify')
second_options_response = http.request(second_options_request)

second_post_request = Net::HTTP::Post.new('/notify')
second_post_request['Content-Type'] = 'application/json'

second_post_request.body = %({
  "first_options_code": "#{first_options_response.code}",
  "first_post_code": "#{first_post_response.code}",
  "second_options_code": "#{second_options_response.code}"
})

http.request(second_post_request)
