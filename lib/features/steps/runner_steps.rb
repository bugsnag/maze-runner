## ENVIRONMENT CONTROL
When("I set environment variable {string} to {string}") do |key, value|
  Runner.environment[key] = value
end
When("I store the endpoint in the environment variable {string}") do |name|
  steps %Q{
    When I set environment variable "#{name}" to "http://maze-runner:#{MOCK_API_PORT}"
  }
end
When("I store the api key in the environment variable {string}") do |name|
  steps %Q{
    When I set environment variable "#{name}" to "#{$api_key}"
  }
end

## SCRIPT RUNNER
When("I run the script {string} synchronously") do |script_path|
  run_script(script_path, blocking: true)
end
When("I run the script {string}") do |script_path|
  run_script script_path
end

## DOCKER RUNNER
When("I start the service {string}") do |service|
  Docker.start_service service
end
When("I run the service {string} with the command {string}") do |service, command|
  Docker.start_service(service, command: command)
end

## EXECUTION TIMING STEPS
When("I wait for {int} second(s)") do |seconds|
  $logger.warn "Sleep was used! Please avoid using sleep in tests!"
  sleep(seconds)
end