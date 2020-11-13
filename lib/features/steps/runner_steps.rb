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
