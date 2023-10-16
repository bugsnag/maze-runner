When('I fail on the first attempt') do
  if $first_attempt
    $first_attempt = false
    fail 'Failing on the first attempt'
  end
end

When('I let the scenario retry') do
  Maze.dynamic_retry = true
end

# Verifies that an environment variable is set to a given value.
#
# @step_input key [String] The environment variable
# @step_input value [String] The intended value of the environment variable
Then('the Runner.environment entry for {string} equals {string}') do |key, expected_value|
  Maze.check.equal(expected_value, Maze::Runner.environment[key])
end

# Verifies that an environment variable is not set.
#
# @step_input key [String] The environment variable
Then('the Runner.environment entry for {string} is null') do |key|
  Maze.check.nil(Maze::Runner.environment[key])
end

