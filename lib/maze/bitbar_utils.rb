# frozen_string_literal: true
require 'fileutils'

module Maze
  # Utils supporting the BitBar device farm integration
  class BitBarUtils
    BB_READY_FILE = 'bb.ready'
    BB_KILL_FILE = 'bb.kill'

    class << self

      # Uploads an app to BitBar for later consumption
      # @param api_key [String] The BitBar API key
      # @param app [String] A path to the application file
      def upload_app(api_key, app)
        uuid_regex = /\A[0-9]+\z/

        if uuid_regex.match? app
          $logger.info "Using pre-uploaded app with ID #{app}"
          app_uuid = app
        else
          expanded_app = Maze::Helper.expand_path(app)
          $logger.info "Uploading app: #{expanded_app}"

          # Upload the app to BitBar
          uri = URI('https://cloud.bitbar.com/api/me/files')
          request = Net::HTTP::Post.new(uri)
          request.basic_auth(api_key, '')
          request.set_form({ 'file' => File.new(expanded_app, 'rb') }, 'multipart/form-data')

          res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
            http.request(request)
          end

          # Pull the UUID from the response
          begin
            response = JSON.parse res.body
            if response.key?('id')
              app_uuid = response['id']
              $logger.info "Uploaded app ID: #{app_uuid}"
              $logger.info 'You can use this ID to avoid uploading the same app more than once.'
            else
              $logger.error "Unexpected response body: #{response}"
              raise 'App upload failed'
            end
          rescue JSON::ParserError
            $logger.error "Expected JSON response, received: #{res.body}"
            raise
          end
        end
        app_uuid
      end

      # Starts the BitBar local tunnel
      # @param bb_local [String] path to the SBSecureTunnel binary
      # @param username [String] Username to start the tunnel with
      # @param access_key [String] BitBar access key
      def start_local_tunnel(bb_local, username, access_key)
        # Make sure the ready/kill files are already deleted
        File.delete(BB_READY_FILE) if File.exist?(BB_READY_FILE)
        File.delete(BB_KILL_FILE) if File.exist?(BB_KILL_FILE)

        $logger.info 'Starting BitBar SBSecureTunnel local tunnel'
        command = "#{bb_local} --username #{username} --authkey #{access_key}" \
                    "--ready #{BB_READY_FILE} --kill #{BB_KILL_FILE}"

        $logger.info command

        @tunnel_shell = Maze::InteractiveCLI.new
        @tunnel_shell.run_command(command)
        success = Maze::Wait.new(timeout: 30).until do
          File.exist?(BB_READY_FILE)
        end
        unless success
          $logger.error "Failed: #{@tunnel_shell.stdout_lines}"
        end
      end

      # Stops the local tunnel
      def stop_local_tunnel
        FileUtils.touch(BB_KILL_FILE)
        Maze::Wait.new(timeout: 30).until do
          !@tunnel_shell.running?
        end
        File.delete(BB_READY_FILE) if File.exist?(BB_READY_FILE)
        File.delete(BB_KILL_FILE) if File.exist?(BB_KILL_FILE)
      end
    end
  end
end
