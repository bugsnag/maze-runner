# frozen_string_literal: true

require 'date'
require 'net/http'
require 'json'

terminating_http = Net::HTTP.new('localhost', '9341')
first_request = Net::HTTP::Post.new('/')
first_request['Content-Type'] = 'application/json'
first_request.body = {
	some_test_data: [
		'some',
		'test',
		'data'
	]
}.to_json

begin
  first_response = terminating_http.request(first_request)
rescue => term_error
  @term_error = term_error
end

http = Net::HTTP.new('localhost', '9339')
second_request = Net::HTTP::Post.new('/notify')
second_request['Content-Type'] = 'application/json'

second_body = {
  error: @term_error.to_s
}

second_body[:response] = first_response.code unless first_response.nil?

second_request.body = second_body.to_json
second_response = http.request(second_request)
