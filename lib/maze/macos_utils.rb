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
        begin
          @screen_recording_pid = Process.spawn(
            'ffmpeg',
            '-y',
            '-f', 'avfoundation',
            '-framerate', '30',
            '-i', '1:none',
            '-pix_fmt', 'yuv420p',
            @screen_recording_path,
            out: File::NULL, err: File::NULL
          )
        rescue StandardError => e
          raise "Failed to start ffmpeg screen recording: #{e.message}"
        end

        # Verify that ffmpeg has actually started and is still running before detaching.
        start_time = Time.now
        loop do
          # Check if the process has already exited.
          pid, status = Process.waitpid2(@screen_recording_pid, Process::WNOHANG)
          if pid
            @screen_recording_pid = nil
            raise "ffmpeg exited immediately while starting screen recording (status #{status.exitstatus})."
          end

          begin
            # Signal 0 checks for process existence without sending a real signal.
            Process.kill(0, @screen_recording_pid)
            break
          rescue Errno::ESRCH
            # Process not yet running or already gone; allow a brief grace period.
          end

          if Time.now - start_time > 5
            @screen_recording_pid = nil
            raise 'ffmpeg did not appear to start screen recording within the expected time.'
          end

          sleep 0.1
        end

        Process.detach(@screen_recording_pid) if @screen_recording_pid
        @screen_recording_path
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
