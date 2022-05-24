# frozen_string_literal: true

module Maze
  class MacosUtils
    class << self
      def screenshot(scenario)
        path = File.join(File.join(Dir.pwd, 'maze_output'), 'failed', scenario.name.gsub(/[:"& ]/, "_").gsub(/_+/, "_"))
        FileUtils.makedirs(path)

        system("/usr/sbin/screencapture #{path}/#{scenario.name.gsub(/[:"& ]/, "_").gsub(/_+/, "_")}-screenshot.jpg")
      end
    end
  end
end