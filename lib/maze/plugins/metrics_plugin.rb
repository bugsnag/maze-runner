# frozen_string_literal: true

require 'logger'
require 'json'

module Maze
  module Plugins
    class MetricsPlugin
      class << self
        def log_event(reference, data={})
          unless Maze.config.tms_uri && Maze.config.tms_token
            $logger.debug 'Log not sent due to missing configuration options'
            return
          end

          send_log({
            reference: reference,
            data: data,
            build_url: ENV['BUILDKITE_BUILD_URL'],
            timestamp: Time.now
          })
        end

        private

        def send_log(log)
          pp 'Send log'
          pp log
          uri = URI("#{Maze.config.tms_uri}/maze_log")
          request = Net::HTTP::Post.new(uri)
          request['Content-Type'] = 'application/json'
          request['Authorization'] = Maze.config.tms_token
          request.body = JSON.generate(log)

          begin
            http = Net::HTTP.new(uri.hostname, uri.port)
            http.request(request)
          rescue => e
            $logger.warn 'Maze event log delivery attempt failed'
            $logger.warn e.message
          else
            $logger.debug 'Maze event log delivered'
          end
        end
      end
    end
  end
end
