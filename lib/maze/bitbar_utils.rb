# frozen_string_literal: true
require 'open3'
require 'fileutils'
require 'json'

module Maze
  # Utils supporting the BitBar device farm integration
  class BitBarUtils
    BB_READY_FILE = 'bb.ready'
    BB_KILL_FILE = 'bb.kill'
    BB_USER_PREFIX = 'BB_USER_'
    BB_KEY_PREFIX = 'BB_KEY_'

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

      # Uploads an app to BitBar for later consumption
      # @param tms_uri [String] The URI of the test-management-service
      #
      # @returns
      def account_credentials(tms_uri)
        Maze::Wait.new(interval: 30, timeout: 1800).until do
          output = request_account_index(tms_uri)
          case output.code
          when '200'
            body = JSON.parse(output.body, {symbolize_names: true})
            @account_id = account_id = body[:id]
            $logger.info "Using account #{account_id}, expiring at #{body[:expiry]}"
            creds = {
              username: ENV["#{BB_USER_PREFIX}#{account_id}"],
              access_key: ENV["#{BB_KEY_PREFIX}#{account_id}"]
            }
          when '409'
            # All accounts are in use, wait for one to become available
            $logger.info 'All accounts are currently in use, retrying in 30s'
            false
          else
            # Something has gone wrong, throw an error
            $logger.error "Unexpected status code received from test-management server"
            raise
          end
        end
      end

      # Uploads an app to BitBar for later consumption
      # @param tms_uri [String] The URI of the test-management-service
      #
      # @returns
      def request_account_index(tms_uri)
        uri = URI("#{tms_uri}/account/request")
        request = Net::HTTP::Get.new(uri)
        res = Net::HTTP.start(uri.hostname, uri.port) do |http|
          http.request(request)
        end
        res
      end

      # Uploads an app to BitBar for later consumption
      # @param tms_uri [String] The URI of the test-management-service
      def release_account(tms_uri)
        uri = URI("#{tms_uri}/account/release?account_id=#{@account_id}")
        request = Net::HTTP::Get.new(uri)
        res = Net::HTTP.start(uri.hostname, uri.port) do |http|
          http.request(request)
        end
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
        command = "#{bb_local} --username #{username} --authkey #{access_key} " \
                    "--ready #{BB_READY_FILE} --kill #{BB_KILL_FILE}"

        output = start_tunnel_thread(command)

        success = Maze::Wait.new(timeout: 30).until do
          File.exist?(BB_READY_FILE)
        end
        unless success
          $logger.error "Failed: #{output}"
        end
      end

      # Stops the local tunnel
      def stop_local_tunnel
        FileUtils.touch(BB_KILL_FILE)
        Maze::Wait.new(timeout: 30).until do
          !File.exist?(BB_READY_FILE)
        end
        File.delete(BB_READY_FILE) if File.exist?(BB_READY_FILE)
        File.delete(BB_KILL_FILE) if File.exist?(BB_KILL_FILE)
      end

      private

      def start_tunnel_thread(cmd)
        executor = lambda do
          Open3.popen2e(Maze::Runner.environment, cmd) do |_stdin, stdout_and_stderr, wait_thr|

            output = []
            stdout_and_stderr.each do |line|
              output << line
              $logger.debug('SBSecureTunnel') {line.chomp}
            end

            exit_status = wait_thr.value.to_i
            $logger.debug "Exit status: #{exit_status}"

            output.each { |line| $logger.warn('SBSecureTunnel') {line.chomp} } unless exit_status == 0

            return [output, exit_status]
          end
        end

        Thread.new(&executor)
      end
    end
  end
end
