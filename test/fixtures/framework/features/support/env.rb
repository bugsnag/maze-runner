Maze.config.enable_bugsnag = false

Maze.hooks.before_all do
  $first_attempt = true
  Maze::Runner.environment['AFTER_CONFIG'] = 'FIRST_SCENARIO_ONLY'
end

Maze.hooks.before do |scenario|
  Maze::Runner.environment['TEST_KEY'] = 'TEST_VALUE' if scenario.name == 'Set variable'
  $first_attempt = true unless Maze::RetryHandler.retried_previously? scenario
end
