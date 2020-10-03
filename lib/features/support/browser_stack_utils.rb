# frozen_string_literal: true

# Utils supporting the BrowserStack device farm integration
class BrowserStackUtils
  # BrowserStack's App Automate upload url
  APP_UPLOAD_URL = 'https://api-cloud.browserstack.com/app-automate/upload'

  # BrowserStack's Appium server url
  APPIUM_SERVER_URL = "http://#{username}:#{access_key}@hub-cloud.browserstack.com/wd/hub"

  class << self

    # Uploads an app to BrowserStack for later consumption
    # @param username [String] the BrowserStack username
    # @param access_key [String] the BrowserStack access key
    def upload_app(username, access_key, app_location)
      res = `curl -u "#{username}:#{access_key}" -X POST "#{BROWSER_STACK_APP_UPLOAD_URL}" -F "file=@#{app_location}"`
      response = JSON.parse(res)
      raise "BrowserStack upload failed due to error: #{response['error']}" if response.include?('error')

      app_url = response['app_url']
      $logger.info "app uploaded to: #{app_url}"
      $logger.info 'You can use this url to avoid uploading the same app more than once.'
      app_url
    end

    # Starts the BrowserStack local tunnel
    # @param key [String] BrowserStack access key
    def start_local_tunnel(key)
      $logger.info 'Starting BrowserStack local tunnel'
      status = nil
      bs_local = MazeRunner.configuration.browser_stack_local
      command = "#{bs_local} -d start --key #{key} --local-identifier local_id --force-local --only-automate --force"
      Open3.popen2(command) do |_stdin, _stdout, wait|
        status = wait.value
      end
      status
    end
  end
end
