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

# Starts an interactive terminal
When('I start a new terminal') do
  Runner.stop_interactive_session
  Runner.get_interactive_session
end

# Stops currently running interactive terminal
When('I stop the current terminal') do
  Runner.stop_interactive_session
end

# Run a command on the terminal
#
# @step_input command [String] The command to run on the terminal
When('I input {string} interactively') do |command|
  current_terminal = Runner.get_interactive_session
  success = current_terminal.run_command(command)
  assert(success, 'The terminal had already closed')
end

# Get the current buffer values in the terminal
#
# @step_input expected_chars [String] The chars present in current buffer
Then('the terminal is outputting {string}') do |expected_chars|
  current_terminal = Runner.get_interactive_session
  assert_equal(expected_chars, current_terminal.current_buffer)
end

# Verify a string appears in the stdout logs
#
# @step_input expected_line [String] The string present in stdout logs
Then('the terminal has output {string}') do |expected_line|
  current_terminal = Runner.get_interactive_session
  match = current_terminal.parsed_output.any? { |line| line == expected_line }
  assert(match, "No output lines matched #{expected_line}")
end

# Verify a string appears in the stderr logs
#
# @step_input expected_err [String] The string present in stderr logs
Then('the terminal has the error message {string}') do |expected_err|
  current_terminal = Runner.get_interactive_session
  match = current_terminal.parsed_errors.any? { |line| line == expected_err }
  assert(match, "No output lines matched #{expected_err}")
end

# Verify the exit code of the terminal
#
# @step_input exit_code [Integer] The expected exit code
Then('the terminal exit code equals {int}') do |exit_code|
  current_terminal = Runner.get_interactive_session
  assert_equal(exit_code, current_terminal.last_exit_code)
end

# Assert that the terminal exited with an error code
#
# @step_input exit_code [Integer] The expected exit code
Then('the terminal exited with an error code') do
  current_terminal = Runner.get_interactive_session
  assert(current_terminal.last_exit_code != 0, "Terminal exited with code 0")
end