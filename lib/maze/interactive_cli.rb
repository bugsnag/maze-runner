require 'pty'
require 'boring'

module Maze
  # Encapsulates a shell session, retaining state and input streams for interactive tests
  class InteractiveCLI
    # @!attribute [r] stdout_lines
    #   @return [Array] An array of output strings received from the terminals STDOUT pipe
    attr_reader :stdout_lines

    # @!attribute [r] stderr_lines
    #   @return [Array] An array of error strings received from the terminals STDERR pipe
    attr_reader :stderr_lines

    # @!attribute [r] pid
    #   @return [Number, nil] The PID of the running terminal
    attr_reader :pid

    # @!attribute [r] current_buffer
    #   @return [String] A string representation of the current output present in the terminal
    attr_reader :current_buffer

    # Creates an InteractiveCLI instance
    #
    # @param shell [String] A path to the shell to run, defaults to `/bin/sh`
    # @param stop_command [String] The stop command, defaults to `exit`
    def initialize(shell = '/bin/sh', stop_command = 'exit')
      @shell = shell
      @stop_command = stop_command
      @stdout_lines = []
      @stderr_lines = []
      @on_exit_blocks = []
      @current_buffer = ''
      @boring = Boring.new

      start_threaded_shell(shell)
    end

    def start(threaded: true)
      threaded ? start_threaded_shell(@shell) : start_shell(@shell)
    end

    # Attempts to stop the shell using the preset command and wait for it to exit
    #
    # @return [Boolean] If the shell stopped successfully
    def stop
      run_command(@stop_command)

      @in_stream.close

      maybe_thread = @thread.join(15)

      # The thread did not exit!
      return false if maybe_thread.nil?

      @pid = nil
      true
    end

    # @return [Boolean] Whether the shell is currently running
    def running?
      !@pid.nil?
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
    rescue ::Errno::EIO => err
      $logger.debug(pid) { "EIO error: #{err}" }
      false
    end

    def on_exit(&block)
      @on_exit_blocks << block
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
      stderr_reader, stderr_writer = IO.pipe

      PTY.spawn(shell, err: stderr_writer.fileno) do |stdout, stdin, pid|
        # We don't need to write to stderr so close it ASAP
        stderr_writer.close

        $logger.debug(pid) { 'PTY spawned!' }
        @pid = pid
        @in_stream = stdin

        stdout_thread = Thread.new do
          stdout.each_char do |char|
            if char == "\n"
              line = format_line(@current_buffer)

              $logger.debug("#{pid} STDOUT") { line.dump }
              @stdout_lines << line
              @current_buffer.clear
            else
              @current_buffer << char
            end
          end
        rescue ::Errno::EIO => err
          $logger.debug(pid) { "EIO error: #{err}" }
        end

        stderr_thread = Thread.new do
          buffer = ''

          stderr_reader.each_char do |char|
            if char == "\n"
              line = format_line(buffer)

              $logger.debug("#{pid} STDERR") { line.dump }
              @stderr_lines << line
              buffer.clear
            else
              buffer << char
            end
          end
        rescue ::Errno::EIO => err
          $logger.debug(pid) { "EIO error: #{err}" }
        end

        _, status = Process.wait2(@pid)
        @pid = nil

        # Stop the thread that's reading from stdout
        failed = stdout_thread.join(5).nil?
        raise 'stdout is blocked!' if failed

        # Stop the thread that's reading from stderr
        failed = stderr_thread.join(5).nil?
        raise 'stderr is blocked!' if failed

        $logger.debug(pid) { "PTY exit status: #{status.exitstatus}" }
        @on_exit_blocks.each do |block|
          block.call(status.exitstatus)
        end
      end
    ensure
      stderr_reader.close unless stderr_reader.closed?
      stderr_writer.close unless stderr_writer.closed?
    end

    def format_line(line)
      @boring.scrub(line.strip)
    end
  end
end
