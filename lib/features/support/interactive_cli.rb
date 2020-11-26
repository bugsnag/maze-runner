require 'open3'

# Encapsulates a shell session, retaining state and input streams for interactive tests
class InteractiveCLI
  # @!attribute [r] stdout_lines
  #   @return [Array] An array of output strings received from the terminals STDOUT pipe
  attr_reader :stdout_lines

  # @!attribute [r] stderr_lines
  #   @return [Array] An array of error strings received from the terminals STDERR pipe
  attr_reader :stderr_lines

  # @!attribute [r] last_exit_code
  #   @return [Number, nil] The exit code of the last terminal command
  attr_reader :last_exit_code

  # @!attribute [r] pid
  #   @return [Number, nil] The PID of the running terminal
  attr_reader :pid

  # @!attribute [r] current_buffer
  #   @return [String] A string representation of the current output present in the terminal
  attr_reader :current_buffer

  # Creates an InteractiveCLI instance
  #
  # @param environment [Hash] A hash of environment variables
  # @param shell [String] A path to the shell to run, defaults to `/bin/sh`
  # @param stop_command [String] The stop command, defaults to `exit`
  def initialize(environment = {}, shell = '/bin/sh', stop_command = 'exit')
    @shell = shell
    @env = environment
    @stdout_lines = []
    @stderr_lines = []
    @current_buffer = ''
    @last_exit_code = nil
    @in_stream = nil
    @pid = nil
    @stop_command = stop_command
    start_threaded_shell(shell)
  end

  def start(threaded = true)
    threaded ? start_threaded_shell(@shell) : start_shell(@shell)
  end

  # Attempts to stop the shell using the preset command and wait for it to exit
  def stop
    run_command(@stop_command)
    wait_for_exit
  end

  # Attempt to wait for the shell to exit. This can fail as it will not kill the
  # shell, instead it expects the shell to be ready to exit
  #
  # @return [Thread, nil] The thread that exited or nil if it didn't exit
  def wait_for_exit
    @in_stream&.close
    @thread&.join(15)
  end

  # Returns whether the shell is running by verifying the in_stream exists and is open
  #
  # @return [Boolean] Whether the stream is currently running
  def running?
    !(@in_stream.nil? || @in_stream.closed?)
  end

  # Runs the given command if the shell is running
  #
  # @param command [String] The command to run
  #
  # @return [Boolean] true if the command is executed, false otherwise
  def run_command(command)
    return false unless running?

    @in_stream.puts(command)
    true
  end

  private

  # Starts a shell on another thread
  #
  # @param shell [String] A path to the shell to run
  def start_threaded_shell(shell)
    @thread = Thread.new do
      start_shell(shell)
    end
  end

  # Starts a shell
  #
  # @param shell [String] A path to the shell to run
  def start_shell(shell)
    exit_status = Open3.popen3(@env, shell) do |stdin, stdout, stderr, wait_thr|
      @in_stream = stdin
      @pid = wait_thr.pid
      $logger.debug(pid) { "Started shell session: #{shell}" }

      stdout_thread = Thread.new do
        stdout.each_char do |char|
          if char == "\n"
            $logger.debug("#{pid} STDOUT") { @current_buffer }
            @stdout_lines << format_line(@current_buffer)
            @current_buffer.clear
          else
            @current_buffer << char
          end
        end
      end

      stderr_thread = Thread.new do
        stderr.each do |raw_line|
          line = format_line(raw_line)

          @stderr_lines << line
          $logger.debug("#{pid} STDERR") { line }
        end
      end

      # Wait for the process to exit. This will usually require 'wait_for_exit'
      # to be called first (via the "I wait for the current shell to exit" step)
      exit_status = wait_thr.value.to_i

      # Stop the thread that's reading from stdout
      failed = stdout_thread.join(5).nil?
      raise 'stdout is blocked!' if failed

      # Stop the thread that's reading from stderr
      failed = stderr_thread.join(5).nil?
      raise 'stderr is blocked!' if failed

      exit_status
    end

    @last_exit_code = exit_status
    $logger.debug(pid) { "exit status: #{exit_status}" }
  end

  # Strips whitespace from shell lines, can be used to sanitize further if required
  def format_line(line)
    line.strip
  end
end
