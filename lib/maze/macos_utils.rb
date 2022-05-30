# frozen_string_literal: true

module Maze
  class MacosUtils
    class << self
      def capture_screen(scenario)
        path = File.join(File.join(Dir.pwd, 'maze_output'), 'failed', Maze::Helper.to_friendly_filename(scenario.name))
        FileUtils.makedirs(path)

        system("/usr/sbin/screencapture #{path}/#{Maze::Helper.to_friendly_filename(scenario.name)}-screenshot.jpg")
      end
    end
  end
end