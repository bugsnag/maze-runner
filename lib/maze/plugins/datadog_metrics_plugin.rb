# frozen_string_literal: true

require 'datadog/statsd'

module Maze
  module Plugins
    class DatadogMetricsPlugin

      class << self
        def send_gauge(metric, value, tags=[])
          return unless logging?
          stats_dog.gauge(metric, value, tags: tags)
        end

        private

        def logging?
          ENV['BUILDKITE']
        end

        def stats_dog
          @stats_dog ||= initialize_stats_dog
        end

        def initialize_stats_dog
          tags = []
          tags << Maze.config.device if Maze.config.device
          tags << Maze.config.farm if Maze.config.farm
          @stats_dog = Datadog::Statsd.new(aws_instance_ip, 8125, tags: tags, namespace: 'maze-runner')
        end

        def aws_instance_ip
          `curl --silent -XGET http://169.254.169.254/latest/meta-data/local-ipv4`
        end
      end
    end
  end
end
