# @!group Runner steps

# Sets an environment variable for subsequent scripts or commands.
#
# @step_input key [String] The environment variable
# @step_input value [String] The intended value of the environment variable
When('I set environment variable {string} to {string}') do |key, value|
  Runner.environment[key] = value
end

# Sets an environment variable to the server endpoint.
#
# @step_input name [String] The environment variable
When('I store the endpoint in the environment variable {string}') do |name|
  steps %Q{
    When I set environment variable "#{name}" to "http://maze-runner:#{MOCK_API_PORT}"
  }
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
  Runner.run_script(script_path, blocking: true)
end

# Runs a script.
#
# @step_input script_path [String] Path to the script to be run
When('I run the script {string}') do |script_path|
  Runner.run_script script_path
end

# Starts a docker-compose service.
#
# @step_input service [String] The name of the service to run
When('I start the service {string}') do |service|
  Docker.start_service service
end

# Runs a docker-compose service using a specific command.
#
# @step_input service [String] The name of the service to run
# @step_input command [String] The command to run inside the service
When('I run the service {string} with the command {string}') do |service, command|
  Docker.start_service(service, command: command)
end

# Runs a docker-compose service using a specific command provided as a Gherkin multi-line string.
#
# @step_input service [String] The name of the service to run
# @step_input command [String] The command to run inside the service (as a Gherkin multi-line string)
When('I run the service {string} with the command') do |service, command|
  one_line_cmd = command.gsub("\n", ' ').gsub(/ +/, ' ')
  Docker.start_service(service, command: one_line_cmd)
end

# Allows validation of the last exit code of the last run docker-compose command.
# Will fail if no commands have been run.
#
# @step_input expected_code [Integer] The expected exit code
Then('the exit code of the last docker command was {int}') do |expected_code|
  exit_code = Docker.last_exit_code
  assert_not_nil(exit_code, 'No docker exit code available to verify')
  assert_equal(exit_code, expected_code)
end

# A shortcut for the above assuming 0 as a successful exit code
# Will fail if no commands have been run
Then('the last run docker command exited successfully') do
  exit_code = Docker.last_exit_code
  assert_not_nil(exit_code, 'No docker exit code available to verify')
  assert_equal(exit_code, 0)
end

# Allows testing that the last exit code was not 0
# Will fail if no commands have been run
Then('the last run docker command did not exit successfully') do
  exit_code = Docker.last_exit_code
  assert_not_nil(exit_code, 'No docker exit code available to verify')
  assert_not_equal(exit_code, 0)
end

# Allows testing a docker command output a specific string
# Will fail if no commands have been run
#
# @step_input expected_string [String] The string expected in a single log line
Then('the last run docker command output {string}') do |expected_string|
  docker_output = Docker.last_command_logs
  assert_not_nil(docker_output, 'No docker logs available to verify')
  output_included = docker_output.any? { |line| line.include?(expected_string) }
  assert(output_included, %(
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
  Runner.stop_interactive_session
  Runner.get_interactive_session
end

# Stops currently running interactive shell
When('I stop the current shell') do
  Runner.stop_interactive_session
end

# Attempts to wait for the currently running interactive shell to exit
When('I wait for the current shell to exit') do
  shell = Runner.get_interactive_session
  result = shell.wait_for_exit

  # The result should be the Thread object if it successfully stopped; if it
  # timed out then 'nil' is returned
  assert_false(result.nil?, 'The shell is still running when it should have exited')
  assert_false(shell.running?, 'The shell is still running when it should have exited')
end

# Run a command on the shell
#
# @step_input command [String] The command to run on the shell
When('I input {string} interactively') do |command|
  current_shell = Runner.get_interactive_session
  success = current_shell.run_command(command)
  assert(success, 'The terminal had already closed')
end

# Get the current buffer values in the shell
#
# @step_input expected_chars [String] The chars present in current buffer
Then('the current stdout line is {string}') do |expected_chars|
  current_shell = Runner.get_interactive_session
  assert_equal(expected_chars, current_shell.current_buffer)
end

# Verify a string appears in the stdout logs
#
# @step_input expected_line [String] The string present in stdout logs
Then('the shell has output {string} to stdout') do |expected_line|
  current_shell = Runner.get_interactive_session
  match = current_shell.stdout_lines.any? { |line| line == expected_line }
  assert(match, "No output lines from #{current_shell.stdout_lines} matched #{expected_line}")
end

# Wait for a string to appear in the stdout logs
#
# @step_input expected_line [String] The string present in stdout logs
Then('I wait for the shell to output {string} to stdout') do |expected_line|
  current_shell = Runner.get_interactive_session

  interval = 0.1
  timeout = MazeRunner.config.receive_requests_wait
  max_attempts = timeout / interval

  attempts = 0
  matches = false

  until matches do
    break if attempts >= max_attempts

    matches = current_shell.stdout_lines.any? { |line| line == expected_line }

    sleep interval unless matches
  end

  assert(matches, "No output lines from #{current_shell.stdout_lines} matched #{expected_line}")
end

# Verify a string appears in the stderr logs
#
# @step_input expected_err [String] The string present in stderr logs
Then('the shell has output {string} to stderr') do |expected_err|
  current_shell = Runner.get_interactive_session
  match = current_shell.stderr_lines.any? { |line| line == expected_err }
  assert(match, "No output lines from #{current_shell.stderr_lines} matched #{expected_err}")
end

# Wait for a string to appear in the stderr logs
#
# @step_input expected_line [String] The string present in stderr logs
Then('I wait for the shell to output {string} to stderr') do |expected_line|
  current_shell = Runner.get_interactive_session

  interval = 0.1
  timeout = MazeRunner.config.receive_requests_wait
  max_attempts = timeout / interval

  attempts = 0
  matches = false

  until matches do
    break if attempts >= max_attempts

    matches = current_shell.stderr_lines.any? { |line| line == expected_line }

    sleep interval unless matches
  end

  assert(matches, "No output lines from #{current_shell.stderr_lines} matched #{expected_line}")
end

# Verify the shell exited successfully (assuming a 0 is a success)
Then('the shell exited successfully') do
  current_shell = Runner.get_interactive_session
  assert_equal(0, current_shell.last_exit_code)
end

# Verify the exit code of the shell
#
# @step_input exit_code [Integer] The expected exit code
Then('the shell exit code is {int}') do |exit_code|
  current_shell = Runner.get_interactive_session
  assert_equal(exit_code, current_shell.last_exit_code)
end

# Assert that the shell exited with an error code (assuming non-0 is an error)
#
# @step_input exit_code [Integer] The expected exit code
Then('the shell exited with an error code') do
  current_shell = Runner.get_interactive_session
  assert(current_shell.last_exit_code != 0, "Shell exited with code 0")
end
