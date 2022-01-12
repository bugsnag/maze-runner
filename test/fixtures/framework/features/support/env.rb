Maze.hooks.before_all do
  Maze::Runner.environment['AFTER_CONFIG'] = 'FIRST_SCENARIO_ONLY'
end

Maze.hooks.before do |scenario|
  Maze::Runner.environment['TEST_KEY'] = 'TEST_VALUE' if scenario.name == 'Set variable'
end

