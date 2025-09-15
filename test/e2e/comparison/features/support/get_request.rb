require 'net/http'

def get_error_config(request_type)
  uri = URI("http://localhost:9339/error-config")

  params = case request_type
  when 'android'
    { :version => '1.2.3', :versionCode => '123', :releaseStage => 'production', :osVersion => '11' }
  when 'ios'
    { :version => '3.2.1', :bundleVersion => '321', :releaseStage => 'production', :osVersion => '15' }
  else
    $logger.error("Unknown request type '#{request_type}'")
    exit(1)
  end

  uri.query = URI.encode_www_form(params)

  headers = {
    'Bugsnag-Api-Key': '12312312312312312312312312312312'
  }

  Net::HTTP.get_response(uri, headers)
end