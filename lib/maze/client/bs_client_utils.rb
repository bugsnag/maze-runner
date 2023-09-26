# frozen_string_literal: true

require 'bugsnag'

module Maze
  module Client
    # Utils supporting the BrowserStack device farm integration
    class BrowserStackClientUtils
      class << self

        # Uploads an app to BrowserStack for later consumption
        # @param username [String] the BrowserStack username
        # @param access_key [String] the BrowserStack access key
        # @param app_id_file [String] the file to write the uploaded app url to BrowserStack
        def upload_app(username, access_key, app, app_id_file=nil)
          if app.start_with? 'bs://'
            app_url = app
            $logger.info "Using pre-uploaded app from #{app}"
          else
            expanded_app = Maze::Helper.expand_path(app)

            uri = URI('https://api-cloud.browserstack.com/app-automate/upload')
            request = Net::HTTP::Post.new(uri)
            request.basic_auth(username, access_key)
            request.set_form({ 'file' => File.new(expanded_app, 'rb') }, 'multipart/form-data')

            upload_tries = 0
            allowed_tries = 10

            while upload_tries < allowed_tries
              begin
                $logger.info "Uploading app: #{expanded_app}"
                res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
                  http.request(request)
                end

                body = res.body
                response = JSON.parse body
                if response.include?('error')
                  $logger.error "Upload failed due to error: #{response['error']}"
                elsif !response.include?('app_url')
                  $logger.error "Upload failed, response did not include an app_url: #{res}"
                else
                  # Successful upload
                  break
                end
              rescue Net::ReadTimeout => error
                Bugsnag.notify error
                $logger.error "Upload failed due to ReadTimeout"
              rescue JSON::ParserError => error
                Bugsnag.notify error
                $logger.error "Unexpected JSON response, received: #{body}"
              end

              upload_tries += 1
              if upload_tries < allowed_tries
                $logger.info 'Retrying upload in 60s'
                Kernel::sleep 60
              end
            end

            if response.nil? || response.include?('error') || !response.include?('app_url')
              raise "Failed to upload app after #{upload_tries} attempts"
            end

            app_url = response['app_url']
            $logger.info "App uploaded to: #{app_url}"
            $logger.info 'You can use this url to avoid uploading the same app more than once.'
          end

          unless app_id_file.nil?
            $logger.info "Writing uploaded app url to #{app_id_file}"
            File.write(Maze::Helper.expand_path(app_id_file), app_url)
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

        # Gets the build/session info from BrowserStack
        # @param username [String] the BrowserStack username
        # @param access_key [String] the BrowserStack access key
        # @param build_name [String] the name of the BrowserStack build
        def build_info(username, access_key, build_name)
          # Get the ID of a build
          uri = URI("https://api.browserstack.com/app-automate/builds.json?name=#{build_name}")
          request = Net::HTTP::Get.new(uri)
          request.basic_auth(username, access_key)

          res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
            http.request(request)
          end

          build_info = JSON.parse(res.body)

          if !build_info.empty?
            build_id = build_info[0]['automation_build']['hashed_id']

            # Get the build info
            uri = URI("https://api.browserstack.com/app-automate/builds/#{build_id}/sessions")
            request = Net::HTTP::Get.new(uri)
            request.basic_auth(username, access_key)

            res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
              http.request(request)
            end

            build_json = JSON.parse(res.body)
          else
            raise "No build found for given ID: #{build_name}"
          end
          build_json
        end

        # @param username [String] the BrowserStack username
        # @param access_key [String] the BrowserStack access key
        # @param name [String] name of the build the log is being downloaded from
        # @param log_url [String] url to the log
        # @param log_type [Symbol] The type of log we are downloading
        def download_log(username, access_key, name, log_url, log_type)
          begin
            path = File.join(Dir.pwd, 'maze_output', log_type.to_s)
            FileUtils.makedirs(path)

            uri = URI(log_url)
            request = Net::HTTP::Get.new(uri)
            request.basic_auth(username, access_key)

            res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
              http.request(request)
            end

            $logger.info "Saving #{log_type.to_s} log to #{path}/#{name}.log"
            File.open("#{path}/#{name}.log", 'w+') { |file| file.write(res.body) }
          rescue StandardError => e
            $logger.warn "Unable to save log from #{log_url}"
            $logger.warn e
          end
        end
      end
    end
  end
end
