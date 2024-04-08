# frozen_string_literal: true

require 'date'
require 'net/http'

http = Net::HTTP.new('localhost', '9339')
command_request = Net::HTTP::Get.new('/command')

command_response = http.request(command_request)

bounce_request = Net::HTTP::Post.new('/notify')
bounce_request['Content-Type'] = 'application/json'
bounce_request.body = %({
  "command_response": #{command_response.body},
  "command_status": #{command_response.code}
})

http.request(bounce_request)
