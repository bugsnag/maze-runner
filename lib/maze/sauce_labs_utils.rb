# frozen_string_literal: true

module Maze
  # Utils supporting the SauceLabs device farm integration
  class SauceLabsUtils
    SC_PID_FILE = 'sc.pid'

    class << self
      attr_accessor :connect_shell

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
        wait = Maze::Wait.new(interval: 0.3, timeout: 3)
        connect_shell = Maze::InteractiveCLI.new
        success = wait.until { connect_shell.running? }
        raise 'Shell session did not start in time!' unless success
        command = "#{sc_local} -u #{username} -k #{access_key} -x #{endpoint} -i #{tunnel_id} -d #{SC_PID_FILE}"
        connect_shell.run_command command
        ready_regex = /Sauce Connect is up, you may start your tests\.$/
        Maze::Wait.new(timeout: 30).until do
          connect_shell.stdout_lines.any? { |line| line.match?(ready_regex) }
        end
      end

      def stop_sauce_connect
        pid = nil
        File.open(SC_PID_FILE, 'r') do |file|
          pid = file.read.to_i
        end
        Process.kill('INT', pid)
        Maze::Wait.new(timeout: 30).until do
          `ps aux | awk '{print $2 }' | grep #{pid}`.empty?
        end
        File.delete(SC_PID_FILE) if File.exist?(SC_PID_FILE)
      end
    end
  end
end
