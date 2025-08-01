# frozen_string_literal: true

require 'datadog/statsd'

module Maze
  module Plugins
    # Enables metrics to be reported to Datadog via a StatsD proxy
    class DatadogMetricsPlugin

      class << self
        # Sends a gauge metric to Datadog
        #
        # @param metric [String] The identifier of the metric
        # @param value [Integer] The value of the metric
        # @param tags [Array] An array of strings with which to tag the metric
        def send_gauge(metric, value, tags=[])
          return unless logging?
          stats_dog.gauge(metric, value, tags: tags)
        end

        # Sends an increment metric to Datadog
        #
        # @param metric [String] The identifier of the metric
        # @param tags [Array] An array of strings with which to tag the metric
        def send_increment(metric, tags=[])
          return unless logging?
          stats_dog.increment(metric, tags: tags)
        end

        private

        # Whether metrics should be delivered to Datadog
        #
        # @returns [Boolean] Whether metrics should be sent
        def logging?
          ENV['BUILDKITE']
        end

        # Returns or initialises the DogStatsD instance
        #
        # @returns [Datadog::Statsd] The DogStatsD instance
        def stats_dog
          @stats_dog ||= initialize_stats_dog
        end

        # Initializes the DogStatsD instance, connecting to the buildkite agent Datadog agent
        #
        # @returns [Datadog::Statsd] The newly created DogStatsD instance
        def initialize_stats_dog
          tags = []
          tags << Maze.config.device.to_s if Maze.config.device
          tags << Maze.config.farm.to_s if Maze.config.farm
          @stats_dog = Datadog::Statsd.new(aws_instance_ip, 8125, tags: tags, namespace: 'maze-runner')

          at_exit do
            @stats_dog.close
          end

          @stats_dog
        end

        # Retrieves the internal ipv4 address of the AWS buildkite instance the maze-runner container is run upon
        #
        # @returns [String] The local ipv4 address the Datadog agent is running on
        def aws_instance_ip
          token = `curl --silent -H "X-aws-ec2-metadata-token-ttl-seconds: 120" -XPUT http://169.254.169.254/latest/api/token`
          `curl -H "X-aws-ec2-metadata-token: #{token}" --silent -XGET http://169.254.169.254/latest/meta-data/local-ipv4`
        end
      end
    end
  end
end
