# frozen_string_literal: true
require 'bugsnag'
require 'open3'
require 'fileutils'
require 'json'

module Maze
  # Utils supporting the BitBar device farm integration
  module Client
    class BitBarClientUtils
      BB_READY_FILE = 'bb.ready'
      BB_KILL_FILE = 'bb.kill'
      BB_USER_PREFIX = 'BB_USER_'
      BB_KEY_PREFIX = 'BB_KEY_'

      class << self

        # Uploads an app to BitBar for later consumption
        # @param api_key [String] The BitBar API key
        # @param app [String] A path to the application file
        # @param app_id_file [String] the file to write the uploaded app url to BitBar
        # @param max_attempts [Integer] the maximum number of attempts to upload the app
        def upload_app(api_key, app, app_id_file=nil, max_attempts=5)
          uuid_regex = /\A[0-9]+\z/

          if uuid_regex.match? app
            $logger.info "Using pre-uploaded app with ID #{app}"
            app_uuid = app
          else
            upload_proc = Proc.new do |app_path|
              $logger.info "Uploading app: #{app_path}"

              # Upload the app to BitBar
              uri = URI('https://cloud.bitbar.com/api/me/files')
              request = Net::HTTP::Post.new(uri)
              request.basic_auth(api_key, '')
              request.set_form({ 'file' => File.new(app_path, 'rb') }, 'multipart/form-data')

              Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
                http.request(request)
              end
            end

            expanded_app = Maze::Helper.expand_path(app)

            attempts = 0
            app_uuid = nil
            last_error = nil
            while attempts < max_attempts && app_uuid.nil?
              attempts += 1
              begin
                response = upload_proc.call(expanded_app)
                body = JSON.parse(response.body)
                if body.key?('id')
                  app_uuid = body['id'].to_s
                  $logger.info "Uploaded app ID: #{app_uuid}"
                  $logger.info 'You can use this ID to avoid uploading the same app more than once.'
                else
                  error_string = "Unexpected response body: #{body}"
                  $logger.error error_string
                  last_error = RuntimeError.new(error_string)
                end
              rescue JSON::ParserError => error
                last_error = error
                Bugsnag.notify error
                $logger.error "Expected JSON response, received: #{response}"
              rescue => error
                last_error = error
                Bugsnag.notify error
                $logger.error "Unexpected error uploading app: #{error}"
              end
            end

            if app_uuid.nil?
              $logger.error "App upload to BitBar failed after #{attempts} attempts"
              raise last_error
            end
          end

          unless app_id_file.nil?
            $logger.info "Writing uploaded app id to #{app_id_file}"
            File.write(Maze::Helper.expand_path(app_id_file), app_uuid)
          end

          app_uuid
        end

        def use_local_tunnel?
          Maze.config.start_tunnel && !Maze.config.aws_public_ip
        end

        # Starts the BitBar local tunnel
        #
        # @param sb_local [String] path to the SBSecureTunnel binary
        # @param username [String] Username to start the tunnel with
        # @param access_key [String] access key
        def start_local_tunnel(sb_local, username, access_key)
          # Make sure the ready/kill files are already deleted
          File.delete(BB_READY_FILE) if File.exist?(BB_READY_FILE)
          File.delete(BB_KILL_FILE) if File.exist?(BB_KILL_FILE)

          $logger.info 'Starting SBSecureTunnel'
          command = "#{sb_local} --username #{username} --authkey #{access_key} --acceptAllCerts " \
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

          success = Maze::Wait.new(timeout: 30).until do
            @tunnel_thread.nil? || !@tunnel_thread.alive?
          end

          if success
            $logger.info("Shutdown SBSecureTunnel")
          else
            $logger.error("Failed to shutdown SBSecureTunnel!")
          end

          @tunnel_thread = nil
          File.delete(BB_READY_FILE) if File.exist?(BB_READY_FILE)
          File.delete(BB_KILL_FILE) if File.exist?(BB_KILL_FILE)
        end

        # Determines capabilities used to organise sessions in the BitBar dashboard.
        #
        # @return [Hash] A hash containing the capabilities.
        def dashboard_capabilities

          # Determine project name
          if ENV['BUILDKITE']
            $logger.info 'Using BUILDKITE_PIPELINE_SLUG for BitBar project name'
            project = ENV['BUILDKITE_PIPELINE_SLUG']
          else
            # Attempt to use the current git repo
            output, status = Maze::Runner.run_command('git rev-parse --show-toplevel')
            if status == 0
              project = File.basename(output[0].strip)
            else
              $logger.warn 'Unable to determine project name, consider running Maze Runner from within a Git repository'
              project = 'Unknown'
            end
          end

          # Test run
          if ENV['BUILDKITE']
            bk_retry = ENV['BUILDKITE_RETRY_COUNT']
            retry_string = if !bk_retry.nil? && bk_retry.to_i > 0
                             " (#{bk_retry})"
                           else
                             ''
                           end
            test_run = "#{ENV['BUILDKITE_BUILD_NUMBER']} - #{ENV['BUILDKITE_LABEL']}#{retry_string}"
          else
            test_run = Maze.run_uuid
          end

          $logger.info "BitBar project name: #{project}"
          $logger.info "BitBar test run: #{test_run}"
          {
            'bitbar:options' => {
              bitbar_project: project,
              bitbar_testrun: test_run
            }
          }
        end


        def get_ids(api_key, project_name = nil)
          base_url = 'https://cloud.bitbar.com/api/me/projects?limit=100'
          url = project_name ? "#{base_url}&filter=name_eq_#{project_name}" : base_url

          uri = URI.parse(url)
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true

          request = Net::HTTP::Get.new(uri.request_uri)
          request.basic_auth(api_key, '')

          begin
            response = http.request(request)
            raise "HTTP request failed with code #{response.code}" unless response.is_a?(Net::HTTPSuccess)
            json_body_data = JSON.parse(response.body)['data']
            json_body_data.map { |project| [project['id'], project['name']] }
          rescue JSON::ParserError
            raise 'Failed to parse JSON response'
          rescue StandardError => e
            raise "An error occurred: #{e.message}"
          end
        end

        def get_unsuccessful_runs(api_key, project_id, date)
          new_date = date_to_milliseconds(date)
          url = URI.parse("https://cloud.bitbar.com/api/me/projects/#{project_id}/runs?filter=successRatio_eq_0.0;d_createTime_on_#{new_date}")

          http = Net::HTTP.new(url.host, url.port)
          http.use_ssl = true

          request = Net::HTTP::Get.new(url.request_uri)
          request.basic_auth(api_key, '')

          begin
            response = http.request(request)
            raise "HTTP request failed with code #{response.code}" unless response.is_a?(Net::HTTPSuccess)
            JSON.parse(response.body)['data']
          rescue JSON::ParserError
            raise 'Failed to parse JSON response'
          rescue StandardError => e
            raise "An error occurred: #{e.message}"
          end
        end

        def date_to_milliseconds(date_string)
          begin
            date_format = "%Y-%m-%d"
            parsed_date = DateTime.strptime(date_string, date_format)
            milliseconds = (parsed_date.to_time.to_f * 1000).to_i
            milliseconds
          rescue ArgumentError
            raise "Invalid date format. Please use YYYY-MM-DD."
          end
        end

        private

        def start_tunnel_thread(cmd)
          executor = lambda do
            Open3.popen2e(Maze::Runner.environment, cmd) do |_stdin, stdout_and_stderr, wait_thr|

              output = []
              stdout_and_stderr.each do |line|
                output << line
              end

              exit_status = wait_thr.value.to_i
              $logger.trace "Exit status: #{exit_status}"

              output.each { |line| $logger.warn('SBSecureTunnel') {line.chomp} } unless exit_status == 0

              return [output, exit_status]
            end
          end

          @tunnel_thread = Thread.new(&executor)
        end
      end
    end
  end
end
