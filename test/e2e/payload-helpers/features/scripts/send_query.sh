#!/usr/bin/env ruby

require 'net/http'
require 'uri'

http = Net::HTTP.new('localhost', ENV['MOCK_API_PORT'])
request = Net::HTTP::Get.new('/reflect?foo=1&bar=b')

request['some-header'] = 'some-value'

http.request(request)
