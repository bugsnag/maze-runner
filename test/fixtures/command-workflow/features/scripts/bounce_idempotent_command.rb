# frozen_string_literal: true

require 'date'
require 'net/http'
require 'json'

target_uuid = ENV['COMMAND_UUID']

http = Net::HTTP.new('localhost', '9339')
command_request = Net::HTTP::Get.new("/command?after=#{target_uuid}")

command_response = http.request(command_request)

bounce_request = Net::HTTP::Post.new('/notify')
bounce_request['Content-Type'] = 'application/json'

begin
  JSON.parse(command_response.body)
  bounce_request.body = %({
    "command_response": #{command_response.body},
    "command_status": #{command_response.code}
  })
rescue
  bounce_request.body = %({
    "command_response": "#{command_response.body}",
    "command_status": #{command_response.code}
  })
end

http.request(bounce_request)
