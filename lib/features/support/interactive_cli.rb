require 'open3'

# Encapsulates a terminal session, retaining state and input streams for interactive tests
class InteractiveCLI
  # @!attribute [r] parsed_output
  #   @return [Array] An array of output strings received from the terminals STDOUT pipe
  attr_reader :parsed_output

  # @!attribute [r] parsed_error
  #   @return [Array] An array of error strings received from the terminals STDERR pipe
  attr_reader :parsed_errors

  # @!attribute [r] last_exit_code
  #   @return [Number] The exit code of the last terminal command
  attr_reader :last_exit_code

  # @!attribute [r] pid
  #   @return [Number] The PID of the running terminal
  attr_reader :pid

  # @!attribute [r] current_buffer
  #   @return [String] A string representation of the current output present in the terminal
  attr_reader :current_buffer

  # Creates an InteractiveCLI instance
  #
  # @param environment [Hash] A hash of environment variables
  # @param terminal [String] A path to the terminal to run, defaults to `/bin/sh`
  # @param terminal [String] The stop command, defaults to `exit`
  def initialize(environment = {}, terminal = '/bin/sh', stop_command = 'exit')
    @env = environment
    @parsed_output = []
    @parsed_errors = []
    @current_buffer = ''
    @last_exit_code = nil
    @in_stream = nil
    @pid = nil
    @running = false
    @stop_command = stop_command
    start_threaded_terminal(terminal)
  end

  # Attempts to stop the terminal using the preset command
  #
  # @return [Boolean] true if successful, false otherwise
  def stop
    run_command(@stop_command)
  end

  # Returns whether the terminal is running by verifying the in_stream exists and is open
  #
  # @return [Boolean] Whether the stream is currently running
  def running
    !(@in_stream.nil? || @in_stream.closed?)
  end

  # Runs the given command if the terminal is running
  #
  # @param command [String] The command to run
  #
  # @return [Boolean] true if successful, false otherwise
  def run_command(command)
    return false unless running
    @in_stream.puts(command)
    true
  end

  private

  # Starts a terminal on another thread
  #
  # @param terminal [String] A path to the terminal to run
  def start_threaded_terminal(terminal)
    executor = lambda do
      start_terminal(terminal)
    end

    Thread.new &executor
  end

  # Starts a terminal
  #
  # @param terminal [String] A path to the terminal to run
  def start_terminal(terminal)
    Open3.popen3(@env, terminal) do |stdin, stdout, stderr, wait_thr|
      @pid = wait_thr.pid
      $logger.debug(pid) { 'Starting terminal session' }

      @in_stream = stdin
      @out_stream = stdout

      stdout.each_char do |char|
        if char == "\n"
          @parsed_output << parse_terminal_line(@current_buffer)
          $logger.debug(pid) { current_buffer }
          @current_buffer.clear
        else
          @current_buffer << char
        end
      end

      stderr.each do |line|
        @parsed_errors << parse_terminal_line(line)
        $logger.debug(pid) { line }
      end

      exit_status = wait_thr.value.to_i
      @last_exit_code = exit_status
      $logger.debug(pid) { "exit status: #{exit_status}" }
    end
  end

  # Strips whitespace from terminal lines, can be used to sanitize further if required
  def parse_terminal_line(line)
    line.strip
  end
end
