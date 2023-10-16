# frozen_string_literal: true

module Maze
  class MacosUtils
    class << self
      def capture_screen(scenario)
        path = Maze::MazeOutput.new(scenario).output_folder
        FileUtils.makedirs(path) unless File.exist?(path)

        system('/usr/sbin/screencapture', "#{path}/#{Maze::Helper.to_friendly_filename(scenario.name)}-screenshot.jpg")
      end
    end
  end
end
