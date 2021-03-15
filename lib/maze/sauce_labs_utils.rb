# frozen_string_literal: true

module Maze
  # Utils supporting the SauceLabs device farm integration
  class SauceLabsUtils
    class << self

      # Uploads an app to Sauce Labs for later consumption
      # @param username [String] the Sauce Labs username
      # @param access_key [String] the Sauce Labs access key
      def upload_app(username, access_key, app)
        uuid_regex = Regexp.new '^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$'

        if uuid_regex.match? app
          $logger.info "Using pre-uploaded app with UUID #{app}"
          app_uuid = app
        else
          expanded_app = Maze::Helper.expand_path(app)
          $logger.info "Uploading app: #{expanded_app}"

          # Upload the app tp Sauce Labs
          uri = URI('https://api.us-west-1.saucelabs.com/v1/storage/upload')
          request = Net::HTTP::Post.new(uri)
          request.basic_auth(username, access_key)
          request.set_form({ 'payload' => File.new(expanded_app, 'rb') }, 'multipart/form-data')

          res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
            http.request(request)
          end

          # Pull the UUID from the response
          begin
            response = JSON.parse res.body

            if response.key?('item') && response['item'].key?('id')
              app_uuid = response['item']['id']
              $logger.info "Uploaded app UUID: #{app_uuid}"
              $logger.info 'You can use this UUID to avoid uploading the same app more than once.'
            else
              $logger.error "Unexpected response body: #{}"
              raise 'App upload failed'
            end
          rescue JSON::ParserError
            $logger.error "Expected JSON response, received: #{body}"
            raise
          end
        end
        app_uuid
      end

      # Sauce Connect
      # @param sc_local [String] path to the Sauce Connect binary
      # @param tunnel_id [String] unique key for the tunnel instance
      # @param username [String] Sauce Labs username
      # @param access_key [String] Sauce Labs access key
      def start_sauce_connect(sc_local, tunnel_id, username, access_key)
        $logger.info 'Starting Sauce Connect tunnel'
        endpoint = 'https://saucelabs.com/rest/v1'
        command = "#{sc_local} -u #{username} -k #{access_key} -x #{endpoint} -i #{tunnel_id} -d sc.pid"
        puts command
        status = nil
        Open3.popen2(command) do |_stdin, _stdout, wait|
          status = wait.value
        end
        status
      end
    end
  end
end
