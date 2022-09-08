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
              app_uuid = response['id'].to_s
              $logger.info "Uploaded app ID: #{app_uuid}"
              $logger.info 'You can use this ID to avoid uploading the same app more than once.'
            else
              $logger.error "Unexpected response body: #{response}"
              raise 'App upload failed'
            end
          rescue JSON::ParserError
            $logger.error "Expected JSON response, received: #{res}"
            raise
          end
        end
        app_uuid
      end

      # Requests an unused account id from the test-management-service
      # @param tms_uri [String] The URI of the test-management-service
      #
      # @returns
      def account_credentials(tms_uri)
        Maze::Wait.new(interval: 10, timeout: 1800).until do
          output = request_account_index(tms_uri)
          case output.code
          when '200'
            body = JSON.parse(output.body, {symbolize_names: true})
            @account_id = account_id = body[:id]
            $logger.info "Using account #{account_id}, expiring at #{body[:expiry]}"
            {
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

      # Makes the HTTP call to acquire an account id
      # @param tms_uri [String] The URI of the test-management-service
      #
      # @returns
      def request_account_index(tms_uri)
        uri = URI("#{tms_uri}/account/request")
        request = Net::HTTP::Get.new(uri)
        request['Authorization'] = Maze.config.tms_token
        res = Net::HTTP.start(uri.hostname, uri.port) do |http|
          http.request(request)
        end
        res
      end

      # Informs the test-management-service that in-use account id is no longer in use
      # @param tms_uri [String] The URI of the test-management-service
      def release_account(tms_uri)
        uri = URI("#{tms_uri}/account/release?account_id=#{@account_id}")
        request = Net::HTTP::Get.new(uri)
        request['Authorization'] = Maze.config.tms_token
        res = Net::HTTP.start(uri.hostname, uri.port) do |http|
          http.request(request)
        end
      end
    end
  end
end
