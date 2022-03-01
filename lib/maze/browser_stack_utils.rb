# frozen_string_literal: true

module Maze
  # Utils supporting the BrowserStack device farm integration
  class BrowserStackUtils
    class << self

      # Uploads an app to BrowserStack for later consumption
      # @param username [String] the BrowserStack username
      # @param access_key [String] the BrowserStack access key
      def upload_app(username, access_key, app)
        if app.start_with? 'bs://'
          app_url = app
          $logger.info "Using pre-uploaded app from #{app}"
        else
          expanded_app = Maze::Helper.expand_path(app)
          $logger.info "Uploading app: #{expanded_app}"

          uri = URI('https://api-cloud.browserstack.com/app-automate/upload')
          request = Net::HTTP::Post.new(uri)
          request.basic_auth(username, access_key)
          request.set_form({ 'file' => File.new(expanded_app, 'rb') }, 'multipart/form-data')

          wait = Maze::Wait.new(interval: 3, timeout: 30)

          result = wait.until(&lambda do 
            res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
              http.request(request)
            end
  
            begin
              body = res.body
              response = JSON.parse body
              raise "Upload failed due to error: #{response['error']}" if response.include?('error')
              raise "Upload failed, response did not include and app_url: #{res}" unless response.include?('app_url')
            rescue JSON::ParserError
              raise "Error: expected JSON response, received: #{body}"
            end            
          end)

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
        command = "#{bs_local} -d start --key #{access_key} --local-identifier #{local_id} " \
                    '--force-local --only-automate --force'

        # Extract the pid from the output so it gets killed at the end of the run
        output = Runner.run_command(command)[0][0]
        begin
          @pid = JSON.parse(output)['pid']
          $logger.info "BrowserStackLocal daemon running under pid #{@pid}"
        rescue JSON::ParserError
          $logger.warn 'Unable to parse pid from output, BrowserStackLocal will be left to die its own death'
        end
      end

      # Stops the local tunnel
      def stop_local_tunnel
        if @pid
          $logger.info "Stopping BrowserStack local tunnel"
          Process.kill('TERM', @pid)
          @pid = nil
        end
      rescue Errno::ESRCH
        # ignored
      end
    end
  end
end
