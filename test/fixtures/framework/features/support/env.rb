# Verifies that an environment variable is set to a given value.
#
# @step_input key [String] The environment variable
# @step_input value [String] The intended value of the environment variable
Then('the Runner.environment entry for {string} equals {string}') do |key, expected_value|
  assert_equal(expected_value, Maze::Runner.environment[key])
end

# Verifies that an environment variable is not set.
#
# @step_input key [String] The environment variable
Then('the Runner.environment entry for {string} is null') do |key|
  assert_nil(Maze::Runner.environment[key])
end

Maze.hooks.before do |scenario|
  Maze::Runner.environment['TEST_KEY'] = 'TEST_VALUE' if scenario.name == 'Set variable'
end

