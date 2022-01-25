# frozen_string_literal: true

require 'bugsnag'
require 'cucumber/core/filter'
require 'json'

# Required to access the options
module Cucumber
  class Configuration
    attr_accessor :options
  end
end

module Maze
  module Plugins
    class CucumberReportPlugin

      def initialize
        configured_data = {
          driver_class: Maze.driver.class,
          device_farm: Maze.config.farm,
          device: Maze.config.device,
          os: Maze.config.os,
          os_version: Maze.config.os_version
        }
        buildkite_data = {
          pipeline: ENV['BUILDKITE_PIPELINE_NAME'],
          repo: ENV['BUILDKITE_REPO'],
          build_url: ENV['BUILDKITE_BUILD_URL'],
          branch: ENV['BUILDKITE_BRANCH'],
          message: ENV['BUILDKITE_MESSAGE'],
          step: ENV['BUILDKITE_LABEL'],
          commit: ENV['BUILDKITE_COMMIT']
        }
        report['configuration'] = configured_data
        report['build'] = buildkite_data
      end

      def install_plugin(cuc_config)
        # Add installation hook
        cuc_config.formats << ['json', {}, json_report_stream]

        # Add exit hook
        at_exit do
          finish_report
        end
      end

      def json_report_stream
        @json_report_stream ||= StringIO.new
      end

      def report
        @report ||= {}
      end

      private

      def finish_report
        session_hash = JSON.parse(json_report_stream.string)
        report[:session] = session_hash
        File.open('out.json', 'w') do |f|
          f.write JSON.pretty_generate(report)
        end
      end
    end
  end
end
