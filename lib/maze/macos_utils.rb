# frozen_string_literal: true

module Maze
  class MacosUtils
    class << self
      def take_screenshot(scenario)
        path = Maze::MazeOutput.new(scenario).output_folder
        FileUtils.makedirs(path) unless File.exist?(path)

        system('/usr/sbin/screencapture', "#{path}/#{Maze::Helper.to_friendly_filename(scenario.name)}-screenshot.jpg")
      end

      def start_screen_recording(scenario)
        unless system('which ffmpeg > /dev/null 2>&1')
          raise 'ffmpeg is not installed or not found in PATH. Please install ffmpeg to use screen recording.'
        end
        path = Maze::MazeOutput.new(scenario).recording
        FileUtils.makedirs(path) unless File.exist?(path)
        filename = "#{Maze::Helper.to_friendly_filename(scenario.name)}-screenrecording.mp4"
        @screen_recording_path = File.join(path, filename)
        # Start ffmpeg screen recording in the background.
        # The macOS screen index used for capture is configurable via the
        # MAZE_MACOS_SCREEN_INDEX environment variable. It defaults to "1"
        # to preserve existing behavior, but note that in AVFoundation device
        # indexes are 0-based and "0" is often the primary display.
        screen_index = ENV.fetch('MAZE_MACOS_SCREEN_INDEX', '1')
        @screen_recording_pid = Process.spawn(
          'ffmpeg',
          '-y',
          '-f', 'avfoundation',
          '-framerate', '30',
          '-i', "#{screen_index}:none",
          '-pix_fmt', 'yuv420p',
          @screen_recording_path,
          out: File::NULL, err: File::NULL
        )
        Process.detach(@screen_recording_pid)
      end

      def stop_screen_recording(_scenario)
        if @screen_recording_pid
          begin
            Process.kill('TERM', @screen_recording_pid)
          rescue Errno::ESRCH
            # Process already exited
          end
          @screen_recording_pid = nil
        end
        @screen_recording_path
      end
    end
  end
end
