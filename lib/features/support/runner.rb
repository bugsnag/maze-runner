# frozen_string_literal: true

require 'open3'
require_relative './interactive_cli'

# Determines the default path to the `scripts` directory.  Can be overwritten in the env.rb file.
SCRIPT_PATH ||= File.expand_path(File.join(File.dirname(__FILE__), '..', 'scripts')) unless defined? SCRIPT_PATH

# Runs scripts and commands, applying relevant environment variables as necessary
class Runner
  class << self
    # Runs a command, applying previously set environment variables.
    # The output from the command is always printed in debug mode -
    # just so the caller can verify something about the output.
    #
    # @param cmd [String] The command to run
    # @param blocking [Boolean] Optional. Whether to wait for a return code before proceeding
    # @param success_codes [Array] Optional. An array of integer codes which indicate the run was successful
    #
    # @return [Array, Thread] If blocking, the output and exit_status are returned
    def run_command(cmd, blocking: true, success_codes: [0])
      executor = lambda do
        $logger.debug "Executing: #{cmd}"

        Open3.popen2e(environment, cmd) do |_stdin, stdout_and_stderr, wait_thr|
          # Add the pid to the list of pids to kill at the end
          pids << wait_thr.pid unless blocking

          output = []
          stdout_and_stderr.each do |line|
            output << line
            $logger.debug line.chomp
          end

          exit_status = wait_thr.value.to_i
          $logger.debug "Exit status: #{exit_status}"

          # if the command fails we log the output at warn level too
          if !success_codes.nil? && !success_codes.include?(exit_status) && $logger.level != Logger::DEBUG
            output.each { |line| $logger.warn(cmd) { line.chomp } }
          end

          return [output, exit_status]
        end
      end

      if blocking
        executor.call
      else
        Thread.new(&executor)
      end
    end

    # Runs a script in the script directory indicated by the SCRIPT_PATH environment variable.
    #
    # @param script_name [String] The name of the script to run
    # @param blocking [Boolean] Optional. Whether to wait for a return code before proceeding
    # @param success_codes [Array] Optional. An array of integer codes which indicate the run was successful
    #
    # @return [Array] If blocking, the output and exit_status are returned
    def run_script(script_name, blocking: false, success_codes: [0])
      script_path = File.join(SCRIPT_PATH, script_name)
      script_path = File.join(Dir.pwd, script_name) unless File.exists? script_path
      if Gem.win_platform?
        # windows does not support the shebang that we use in the scripts so it
        # needs to know how to execute the script. Passing `cmd /c` tells windows
        # to use it's known file associations to execute this path. If ruby is
        # installed on windows then it will know that `rb` files should be exceuted
        # using ruby etc.
        script_path = "cmd /c #{script_path}"
      end
      run_command(script_path, blocking: blocking, success_codes: success_codes)
    end

    # Returns the current interactive session, creating a new one if necessary
    #
    # @return [InteractiveCLI] The interactiveCLI instance
    def get_interactive_session(*args)
      return @interactive_session unless @interactive_session.nil?

      interactive_session = InteractiveCLI.new(environment, *args)

      attempts = 0

      until interactive_session.pid
        raise "Shell session would not start within 3 seconds" if attempts > 10 # allows 3 seconds of opening

        attempts += 1
        sleep(0.3)
      end

      @interactive_session = interactive_session
    end

    # Stops the interactive session, allowing a new one to be started
    def stop_interactive_session
      return if @interactive_session.nil?

      @interactive_session.stop

      # Make sure the process is properly ended
      pids << @interactive_session.pid if @interactive_session.pid
      @interactive_session = nil
    end

    # Stops all script processes previously started by this class.
    def kill_running_scripts
      stop_interactive_session
      pids.each do |p|
        Process.kill('KILL', p)
      rescue Errno::ESRCH
        # ignored
      end
      pids.clear
    end

    # Allows access to a hash of environment variables applied to command and script runs.
    #
    # @return [Hash] The hash of currently set environment variables and their values
    def environment
      @environment ||= {}
    end

    private

    def pids
      @pids ||= []
    end
  end
end
