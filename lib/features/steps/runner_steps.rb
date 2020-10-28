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

# Verify a string appears in the stderr logs
#
# @step_input expected_err [String] The string present in stderr logs
Then('the shell has output {string} to stderr') do |expected_err|
  current_shell = Runner.get_interactive_session
  match = current_shell.stderr_lines.any? { |line| line == expected_err }
  assert(match, "No output lines from #{current_shell.stderr_lines} matched #{expected_err}")
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