module Maze
  # Responsible for writing files to the maze_output directory
  class MazeOutput

    # @param scenario The Cucumber scenario
    def initialize(scenario)
      @scenario = scenario
    end

    # Writes each list of requests to a separate file under, e.g:
    # maze_output/failed/scenario_name/errors.log
    def write_requests
      path = output_folder
      FileUtils.makedirs(path)

      request_types = %w[errors sessions builds uploads logs sourcemaps traces invalid reflections pipeline_events]
      request_types << 'sampling requests'

      request_types.each do |request_type|
        list = Maze::Server.list_for(request_type).all
        next if list.empty?

        filename = "#{request_type.gsub(' ', '_')}.log"
        filepath = File.join(path, filename)

        counter = 1
        File.open(filepath, 'w+') do |file|
          list.each do |request|
            file.puts "=== Request #{counter} of #{list.size} ==="
            file.puts

            if request[:invalid]
              invalid_request = true
              uri = request[:request][:request_uri]
              headers = request[:request][:header]
              body = request[:request][:body]
            else
              invalid_request = false
              uri = request[:request].request_uri
              headers = request[:request].header
              body = request[:body]
            end

            file.puts "URI: #{uri}"
            file.puts

            # Request
            file.puts "Request:"
            headers.each do |key, values|
              file.puts "  #{key}: #{values.map {|v| "'#{v}'"}.join(' ')}"
            end
            file.puts

            if request.include?(:query)
              file.puts "Query:"
              file.puts JSON.pretty_generate(request[:query])
            end

            file.puts "Request body:"
            if !invalid_request && headers["content-type"].first == 'application/json'
              file.puts JSON.pretty_generate(body)
            else
              file.puts body
            end
            file.puts
            if request.include?(:reason)
              file.puts "REASON:"
              file.puts request[:reason]
              file.puts
            end
            file.puts

            file.puts "Request digests:"
            file.puts JSON.pretty_generate(request[:digests])
            file.puts

            # Response
            response = request[:response]
            file.puts "Response headers:"
            file.puts JSON.pretty_generate(response.header)
            file.puts

            file.puts "Response body: #{response.body}"
            file.puts
            file.puts

            counter += 1
          end
        end
      end
    end

    # Pulls the logs from the device if the scenario fails
    # @param logs [Array<String>] The lines of log to be written
    def write_device_logs(logs)

      dir = output_folder
      FileUtils.makedirs(dir)
      filepath = File.join(dir, 'device.log')

      File.open(filepath, 'w+') do |file|
        logs.each { |line| file.puts line }
      end
    end

    # Determines the output folder for the scenario
    def output_folder
      folder1 = File.join(Dir.pwd, 'maze_output')
      folder2 = @scenario.failed? ? 'failed' : 'passed'
      folder3 = Maze::Helper.to_friendly_filename(@scenario.name)

      File.join(folder1, folder2, folder3)
    end
  end
end
