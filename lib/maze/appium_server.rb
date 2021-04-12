# frozen_string_literal: true

require 'pty'
require 'logger'

module Maze
  # Basic shell that runs an Appium server on a separate thread
  class AppiumServer
    class << self
      # @return [string|nil] The PID of the appium process (if available)
      attr_reader :pid

      # @return [thread|nil] The thread running the appium process (if available)
      attr_reader :appium_thread

      # @return [Logger|nil] The logger used for creating the log file
      attr_reader :appium_logger

      # Starts a separate thread running the appium server so long as:
      #   - An instance of the appium server isn't already running
      #   - The port configured is available
      #   - The appium command is available via CLI
      #
      # @param address [String] The IP address on which to start the appium server
      # @param port [String] The port on which to start the appium server
      def start(address: '0.0.0.0', port: '4723')
        return if running

        # Check if the appium server appears to be running already, warning and carrying on if so
        unless appium_port_available?(port)
          $logger.warn "Requested appium port:#{port} is in use. Aborting built-in appium server launch"
          return
        end

        # Check if appium is installed, warning if not
        unless appium_available?
          $logger.warn 'Appium is unavailable to be started from the command line. Install using `npm i -g appium`'
          return
        end

        start_logger

        command = "appium -a #{address} -p #{port}"
        @appium_thread = Thread.new do
          PTY.spawn(command) do |stdout, _stdin, pid|
            @pid = pid
            $logger.debug("Appium:#{@pid}") { 'Appium server started' }
            stdout.each do |line|
              log_line(line)
            end
          end
        end

        # Temporary sleep to allow appium to start
        sleep 2
      end

      # Checks whether the server is running, as indicated by the @pid and the appium thread being alive
      #
      # @return [Boolean] Whether the local appium server is running
      def running
        @appium_thread&.alive? ? true : false
      end

      # Stops the appium server, if running, using SIGINT for correct shutdown
      def stop
        return unless running

        $logger.debug("Appium:#{@pid}") { 'Stopping appium server' }
        Process.kill('INT', @pid)
        @pid = nil
        @appium_thread.join
        @appium_thread = nil
      end

      private

      # Checks if the `appium` command is available on CI
      #
      # @return [Boolean] Whether the appium command is available
      def appium_available?
        `appium -v`
        true
      rescue Errno::ENOENT
        false
      end

      # Starts the logger targeting a file defined by the APPIUM_LOGFILE config option
      def start_logger
        @appium_logger = ::Logger.new(Maze.config.appium_logfile)
        @appium_logger.datetime_format = '%Y-%m-%d %H:%M:%S'
      end

      # Logs to a known file, creating the outstream if it isn't already present
      #
      # @param line [String] The line to log
      def log_line(line)
        return if @appium_logger.nil?
        @appium_logger.info("Appium:#{@pid}") { line }
      end

      # Checks if the given port is already in use
      #
      # @param port [String] The port that should be available
      #
      # @return [Boolean] Whether something is running on the given port
      def appium_port_available?(port)
        `netstat -vanp tcp | awk '{ print $4 }' | grep "\.#{port}$"`.empty?
      end
    end
  end
end
