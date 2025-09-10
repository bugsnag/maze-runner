require 'net/http'

request_type = ENV['request_type']
uri = URI("http://localhost:#{ENV['MOCK_API_PORT']}/error-config")

puts "Requesting error config for type '#{request_type}'"

params = case request_type
when 'android error-config'
  { :version => '1.2.3', :versionCode => '123', :releaseStage => 'production', :osVersion => '11' }
when 'ios error-config'
  { :version => '3.2.1', :bundleVersion => '321', :releaseStage => 'production', :osVersion => '15' }
else
  exit(1)
end

uri.query = URI.encode_www_form(params)

headers = {
  'Bugsnag-Api-Key': '12312312312312312312312312312312'
}
res = Net::HTTP.get_response(uri, headers)
puts res.body
