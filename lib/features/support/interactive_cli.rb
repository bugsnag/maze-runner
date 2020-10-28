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
    @running = false
    @stop_command = stop_command
    start_threaded_shell(shell)
  end

  def start(threaded = true)
    threaded ? start_threaded_shell(@shell) : start_shell(@shell)
  end

  # Attempts to stop the shell using the preset command
  def stop
    run_command(@stop_command)
    @thread&.join(5)
  end

  # Returns whether the shell is running by verifying the in_stream exists and is open
  #
  # @return [Boolean] Whether the stream is currently running
  def running
    !(@in_stream.nil? || @in_stream.closed?)
  end

  # Runs the given command if the shell is running
  #
  # @param command [String] The command to run
  #
  # @return [Boolean] true if the command is executed, false otherwise
  def run_command(command)
    return false unless running
    @in_stream.puts(command)
    true
  end

  private

  # Starts a shell on another thread
  #
  # @param shell [String] A path to the shell to run
  def start_threaded_shell(shell)
    executor = lambda do
      start_shell(shell)
    end
    @thread = Thread.new &executor
  end

  # Starts a shell
  #
  # @param shell [String] A path to the shell to run
  def start_shell(shell)
    Open3.popen3(@env, shell) do |stdin, stdout, stderr, wait_thr|
      @pid = wait_thr.pid
      $logger.debug(pid) { "Starting shell session: #{shell}" }

      @in_stream = stdin

      stdout.each_char do |char|
        if char == "\n"
          @stdout_lines << format_line(@current_buffer)
          $logger.debug(pid) { @current_buffer }
          @current_buffer.clear
        else
          @current_buffer << char
        end
      end

      stderr.each do |line|
        @stderr_lines << format_line(line)
        $logger.debug(pid) { line }
      end

      exit_status = wait_thr.value.to_i
      @last_exit_code = exit_status
      $logger.debug(pid) { "exit status: #{exit_status}" }
    end
  end

  # Strips whitespace from shell lines, can be used to sanitize further if required
  def format_line(line)
    line.strip
  end
end
