require 'securerandom'
require_relative '../../maze/wait'

# @!group Runner steps

# Sets an environment variable for subsequent scripts or commands.
#
# @step_input key [String] The environment variable
# @step_input value [String] The intended value of the environment variable
When('I set environment variable {string} to {string}') do |key, value|
  Maze::Runner.environment[key] = value
end

# Sets an environment variable to a given endpoint.
#
# @step_input endpoint [String] The endpoint to set
# @step_input name [String] The environment variable
When('I store the {word} endpoint in the environment variable {string}') do |endpoint, name|
  steps %(
    When I set environment variable "#{name}" to "http://maze-runner:#{Maze.config.port}/#{endpoint}"
  )
end

# Sets an environment variable to the currently set API key.
#
# @step_input name [String] The environment variable
When('I store the api key in the environment variable {string}') do |name|
  steps %Q{
    When I set environment variable "#{name}" to "#{$api_key}"
  }
end

# Runs a script, blocking until it returns.
#
# @step_input script_path [String] Path to the script to be run
When('I run the script {string} synchronously') do |script_path|
  Maze::Runner.run_script(script_path, blocking: true)
end

# Runs a script with a given interpreter, blocking until it returns.
#
# @step_input script_path [String] Path to the script to be run
# @step_input command [String] The command to run the script with, e.g. 'ruby'
When('I run the script {string} using {word} synchronously') do |script_path, command|
  Maze::Runner.run_script(script_path, blocking: true, command: command)
end

# Runs a script.
#
# @step_input script_path [String] Path to the script to be run
When('I run the script {string}') do |script_path|
  Maze::Runner.run_script script_path
end

# Starts a docker-compose service.
#
# @step_input service [String] The name of the service to run
When('I start the service {string}') do |service|
  Maze::Docker.start_service service
end

# Runs a docker-compose service using a specific command.
#
# @step_input service [String] The name of the service to run
# @step_input command [String] The command to run inside the service
When('I run the service {string} with the command {string}') do |service, command|
  Maze::Docker.start_service(service, command: command)
end

# Runs a docker-compose service in an interactive CLI.
#
# @step_input service [String] The name of the service to run
When('I run the service {string} interactively') do |service|
  # Stop the old session if one exists
  step('I stop the current shell') if Maze::Runner.interactive_session?

  Maze::Docker.start_service(service, interactive: true)
end

# Runs a docker-compose service using a specific command in an interactive CLI.
#
# @step_input service [String] The name of the service to run
# @step_input command [String] The command to run inside the service
When('I run the service {string} with the command {string} interactively') do |service, command|
  # Stop the old session if one exists
  step('I stop the current shell') if Maze::Runner.interactive_session?

  Maze::Docker.start_service(service, command: command, interactive: true)
end

# Runs a docker-compose service using a specific command provided as a Gherkin multi-line string.
#
# @step_input service [String] The name of the service to run
# @step_input command [String] The command to run inside the service (as a Gherkin multi-line string)
When('I run the service {string} with the command') do |service, command|
  one_line_cmd = command.gsub("\n", ' ').gsub(/ +/, ' ')
  Maze::Docker.start_service(service, command: one_line_cmd)
end

# Executes a command in the given docker compose service.
#
# The service must already be running for this to succeed as it uses 'docker
# compose exec'.
#
# @step_input command [String] The command to run inside the service
# @step_input service [String] The name of the service
When('I execute the command {string} in the service {string}') do |command, service|
  Maze::Docker.exec(service, command)
end

# Executes a command in the given docker compose service in the background.
#
# The service must already be running for this to succeed as it uses 'docker
# compose exec --detach'.
#
# @step_input command [String] The command to run inside the service
# @step_input service [String] The name of the service
When('I execute the command {string} in the service {string} in the background') do |command, service|
  Maze::Docker.exec(service, command, detach: true)
end

# Allows validation of the last exit code of the last run docker-compose command.
# Will fail if no commands have been run.
#
# @step_input expected_code [Integer] The expected exit code
Then('the exit code of the last docker command was {int}') do |expected_code|
  wait = Maze::Wait.new(timeout: Maze.config.receive_requests_wait)
  success = wait.until { !Maze::Docker.last_exit_code.nil? }

  Maze.check.true(success, 'No docker exit code available to verify')
  Maze.check.equal(Maze::Docker.last_exit_code, expected_code)
end

# A shortcut for the above assuming 0 as a successful exit code
# Will fail if no commands have been run
Then('the last run docker command exited successfully') do
  step('the exit code of the last docker command was 0')
end

# Allows testing that the last exit code was not 0
# Will fail if no commands have been run
Then('the last run docker command did not exit successfully') do
  wait = Maze::Wait.new(timeout: Maze.config.receive_requests_wait)
  success = wait.until { !Maze::Docker.last_exit_code.nil? }

  Maze.check.true(success, 'No docker exit code available to verify')
  Maze.check.not_equal(Maze::Docker.last_exit_code, 0)
end

# Allows testing a docker command output a specific string
# Will fail if no commands have been run
#
# @step_input expected_string [String] The string expected in a single log line
Then('the last run docker command output {string}') do |expected_string|
  wait = Maze::Wait.new(timeout: Maze.config.receive_requests_wait)
  success = wait.until { !Maze::Docker.last_command_logs.nil? }

  Maze.check.true(success, 'No docker logs available to verify')

  docker_output = Maze::Docker.last_command_logs
  output_included = docker_output.any? { |line| line.include?(expected_string) }

  Maze.check.true(output_included, %(
    No line of output included '#{expected_string}'.
    Full output:
    #{docker_output.join('\n')}
  ))
end

# Waits for a number of seconds, performing no actions.
#
# @step_input seconds [Integer] The number of seconds to sleep for
When('I wait for {int} second(s)') do |seconds|
  $logger.warn 'Sleep was used! Please avoid using sleep in tests!'
  sleep(seconds)
end

# Starts an interactive shell
When('I start a new shell') do
  # Stop the old session if one exists
  step('I stop the current shell') if Maze::Runner.interactive_session?

  Maze::Runner.start_interactive_session
end

# Stops currently running interactive shell
When('I stop the current shell') do
  shell = Maze::Runner.interactive_session
  result = Maze::Runner.stop_interactive_session

  Maze.check.true(result, 'The shell is still running when it should have exited')
  Maze.check.false(shell.running?, 'The shell is still running when it should have exited')
end

# Run a command on the shell
#
# @step_input command [String] The command to run on the shell
When('I input {string} interactively') do |command|
  current_shell = Maze::Runner.interactive_session
  success = current_shell.run_command(command)
  Maze.check.true(success, 'The terminal had already closed')
end

# Send a return or enter to the interactive session
When('I input a return interactively') do
  step('I input "" interactively')
end

# Assert the current stdout line in the shell exactly matches the given string
#
# @step_input expected [String] The expected string
Then('the current stdout line is {string}') do |expected|
  current_shell = Maze::Runner.interactive_session
  Maze.check.equal(expected, current_shell.current_buffer)
end

# Assert the current stdout line in the shell includes the given string
#
# @step_input expected [String] The expected string
Then('the current stdout line contains {string}') do |expected|
  current_shell = Maze::Runner.interactive_session
  Maze.check.include(current_shell.current_buffer, expected)
end

# Waits for a line matching a regex to be present in the current stdout
# Times out after Maze.config.receive_requests_wait seconds.
#
# @step_input regex [String] The regex to match against
Then('I wait for the current stdout line to match the regex {string}') do |regex|
  wait = Maze::Wait.new(timeout: Maze.config.receive_requests_wait)
  shell = Maze::Runner.interactive_session

  success = wait.until { shell.current_buffer.match?(regex) }

  Maze.check.true(success, "The current output line \"#{shell.current_buffer}\" did not match \"#{regex}\"")
end

# Waits for a specific shell prompt to be present in the buffered stdout line,
# timing out after Maze.config.receive_requests_wait seconds.
#
# @step_input expected_prompt [String] The prompt expected in the current buffer
Then('I wait for the shell prompt {string}') do |expected_prompt|
  wait = Maze::Wait.new(timeout: Maze.config.receive_requests_wait)
  shell = Maze::Runner.interactive_session

  success = wait.until { expected_prompt == sanitized(shell.current_buffer) }

  Maze.check.true(success, "The current output line \"#{shell.current_buffer}\" did not match \"#{expected_prompt}\"")
end

# Verify a string appears in the stdout logs
#
# @step_input expected_line [String] The string present in stdout logs
Then('the shell has output {string} to stdout') do |expected_line|
  current_shell = Maze::Runner.interactive_session
  match = current_shell.stdout_lines.any? { |line| line == expected_line }
  Maze.check.true(match, "No output lines from #{current_shell.stdout_lines} matched #{expected_line}")
end

# Wait for a string to appear in the stdout logs, timing out after Maze.config.receive_requests_wait seconds.
#
# @step_input expected_line [String] The string present in stdout logs
Then('I wait for the shell to output {string} to stdout') do |expected_line|
  wait = Maze::Wait.new(timeout: Maze.config.receive_requests_wait)
  current_shell = Maze::Runner.interactive_session

  success = wait.until do
    current_shell.stdout_lines.any? do |line|
      # Remove inconsequential escape codes
      expected_line == sanitized(line)
    end
  end

  Maze.check.true(success, "No output lines from #{current_shell.stdout_lines} matched #{expected_line}")
end

def sanitized(line)
  line.sub "\e[?25h", '' # Make cursor visible
end

# Verify a string using a regex in the stdout logs
#
# @step_input regex_matcher [String] The regex expected to match a line in stdout logs
Then('the shell has output a match for the regex {string} to stdout') do |regex_matcher|
  current_shell = Maze::Runner.interactive_session
  match = current_shell.stdout_lines.any? { |line| line.match?(regex_matcher) }
  Maze.check.true(match, "No output lines from #{current_shell.stdout_lines} matched #{regex_matcher}")
end

# Wait for a string matching a regex in the stdout logs, timing out after Maze.config.receive_requests_wait seconds.
#
# @step_input regex_matcher [String] The regex expected to match a line in stdout logs
Then('I wait for the shell to output a match for the regex {string} to stdout') do |regex_matcher|
  wait = Maze::Wait.new(timeout: Maze.config.receive_requests_wait)
  current_shell = Maze::Runner.interactive_session

  success = wait.until do
    current_shell.stdout_lines.any? { |line| line.match?(regex_matcher) }
  end

  Maze.check.true(success, "No output lines from #{current_shell.stdout_lines} matched #{regex_matcher}")
end

# Wait for the shell to output a number of strings in STDOUT, as defined by a table.
# This step will time out after Maze.config.receive_requests_wait seconds.
#
# @step_input expected_lines [Array] An array of strings expected in STDOUT
Then('I wait for the interactive shell to output the following lines in stdout') do |expected_lines|
  wait = Maze::Wait.new(timeout: Maze.config.receive_requests_wait)
  current_shell = Maze::Runner.interactive_session

  success = wait.until do
    current_stdout = current_shell.stdout_lines.join("\n")
    current_stdout.include?(expected_lines)
  end

  Maze.check.true(
    success,
    "Lines present in stdout: #{current_shell.stdout_lines} did not include all of: #{expected_lines}"
  )
end

# Verify a string appears in the stderr logs
#
# @step_input expected_err [String] The string present in stderr logs
Then('the shell has output {string} to stderr') do |expected_err|
  current_shell = Maze::Runner.interactive_session
  match = current_shell.stderr_lines.any? { |line| line == expected_err }
  Maze.check.true(match, "No output lines from #{current_shell.stderr_lines} matched #{expected_err}")
end

# Wait for a string to appear in the stderr logs
#
# @step_input expected_line [String] The string present in stderr logs
Then('I wait for the shell to output {string} to stderr') do |expected_line|
  wait = Maze::Wait.new(timeout: Maze.config.receive_requests_wait)
  current_shell = Maze::Runner.interactive_session

  success = wait.until do
    current_shell.stderr_lines.any? { |line| line == expected_line }
  end

  Maze.check.true(success, "No output lines from #{current_shell.stderr_lines} matched #{expected_line}")
end

# Verify the last interactive command exited successfully (assuming a 0 is a success)
Then('the last interactive command exited successfully') do
  Maze.check.true(
    Maze::Runner.interactive_session?,
    'No interactive session is running so the exit code cannot be checked'
  )

  uuid = SecureRandom.uuid

  steps %Q{
    When I input "[ $? = 0 ] && echo '#{uuid} exited with 0' || echo '#{uuid} exited with error'" interactively
    Then I wait for the shell to output a match for the regex "#{uuid} exited with 0" to stdout
  }
end

# Verify the exit code of the last interactive command
#
# @step_input exit_code [Integer] The expected exit code
Then('the last interactive command exit code is {int}') do |exit_code|
  Maze.check.true(
    Maze::Runner.interactive_session?,
    'No interactive session is running so the exit code cannot be checked'
  )

  uuid = SecureRandom.uuid

  steps %Q{
    When I input "echo #{uuid} $?" interactively
    Then I wait for the shell to output a match for the regex "#{uuid} #{exit_code}" to stdout
  }
end

# Assert that the last interactive command exited with an error code (assuming non-0 is an error)
Then('the last interactive command exited with an error code') do
  Maze.check.true(
    Maze::Runner.interactive_session?,
    'No interactive session is running so the exit code cannot be checked'
  )

  uuid = SecureRandom.uuid

  steps %Q{
    When I input "[ $? = 0 ] && echo '#{uuid} exited with 0' || echo '#{uuid} exited with error'" interactively
    Then I wait for the shell to output a match for the regex "#{uuid} exited with error" to stdout
  }
end

# Assert that an expected_line is present in a file located relative to the interactive terminal's CWD
#
# @step_input filename [String] The file tested, relative to the CWD of the interactive terminal
# @step_input expected_line [String] The line expected in the file
Then('the interactive file {string} contains {string}') do |filename, expected_line|
  steps %(
    When I input "fgrep '#{expected_line.gsub(/"/, '\"')}' #{filename}" interactively
    And I wait for the current stdout line to match the regex "[#>$]\\s?"
    Then the last interactive command exited successfully
  )
end

# Assert that a line is not present in a file located relative to the interactive terminal's CWD
#
# @step_input filename [String] The file tested, relative to the CWD of the interactive terminal
# @step_input excluded_line [String] The line that should not be present be in the file
Then('the interactive file {string} does not contain {string}') do |filename, excluded_line|
  steps %(
    When I input "fgrep '#{excluded_line.gsub(/"/, '\"')}' #{filename}" interactively
    And I wait for the current stdout line to match the regex "[#>$]\\s?"
    Then the last interactive command exited with an error code
  )
end

# Assert that a file located relative to the CWD of the interactive terminal contains all of the expected lines
#
# @step_input filename [String] The file tested, relative to the CWD of the interactive terminal
# @step_input expected_lines [String] The lines expected in the file as a multi-line string
Then('the interactive file {string} contains:') do |filename, expected_lines|
  expected_lines.each_line do |line|
    step("the interactive file '#{filename}' contains '#{line.chomp}'")
  end
end

# Assert that a file located relative to the CWD of the interactive terminal does not contain any of the excluded lines
#
# @step_input filename [String] The file tested, relative to the CWD of the interactive terminal
# @step_input excluded_lines [String] The lines that should not be present in the file, as a multi-line string
Then('the interactive file {string} does not contain:') do |filename, excluded_lines|
  excluded_lines.each_line do |line|
    step("the interactive file '#{filename}' does not contain '#{line.chomp}'")
  end
end
