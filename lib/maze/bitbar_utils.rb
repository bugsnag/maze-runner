# frozen_string_literal: true

module Maze
  # Utils supporting the BitBar device farm integration
  class BitBarUtils
    class << self
      attr_accessor :connect_shell

      # Uploads an app to BitBar for later consumption
      # @param api_key [String] The BitBar API key
      # @param app [String] A path to the application file
      def upload_app(api_key, app)
        pp app
        uuid_regex = /\A[0-9]{8,12}\z/

        if uuid_regex.match? app
          $logger.info "Using pre-uploaded app with UUID #{app}"
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
              $logger.info "Uploaded app UUID: #{app_uuid}"
              $logger.info 'You can use this UUID to avoid uploading the same app more than once.'
            else
              $logger.error "Unexpected response body: #{response}"
              raise 'App upload failed'
            end
          rescue JSON::ParserError
            $logger.error "Expected JSON response, received: #{body}"
            raise
          end
        end
        app_uuid
      end
    end
  end
end
