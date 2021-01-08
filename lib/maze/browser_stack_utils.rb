# frozen_string_literal: true

module Maze
  # Utils supporting the BrowserStack device farm integration
  class BrowserStackUtils
    class << self

      # Uploads an app to BrowserStack for later consumption
      # @param username [String] the BrowserStack username
      # @param access_key [String] the BrowserStack access key
      def upload_app(username, access_key, app)
        # TODO: Improve error handling:
        #   - res may not be JSON at all
        if app.start_with? 'bs://'
          app_url = app
          $logger.info "Using pre-uploaded app from #{app}"
        else
          url = 'https://api-cloud.browserstack.com/app-automate/upload'
          res = `curl -u "#{username}:#{access_key}" -X POST "#{url}" -F "file=@#{app}"`
          response = JSON.parse(res)
          raise "BrowserStack upload failed due to error: #{response['error']}" if response.include?('error')

          app_url = response['app_url']
          $logger.info "app uploaded to: #{app_url}"
          $logger.info 'You can use this url to avoid uploading the same app more than once.'
        end
        app_url
      end

      # Starts the BrowserStack local tunnel
      # @param bs_local [String] path to the BrowserStackLocal binary
      # @param local_id [String] unique key for the tunnel instance
      # @param access_key [String] BrowserStack access key
      def start_local_tunnel(bs_local, local_id, access_key)
        $logger.info 'Starting BrowserStack local tunnel'
        status = nil
        command = "#{bs_local} -d start --key #{access_key} --local-identifier #{local_id} " \
                    '--force-local --only-automate --force'
        Open3.popen2(command) do |_stdin, _stdout, wait|
          status = wait.value
        end
        status
      end
    end
  end
end
