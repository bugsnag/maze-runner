MazeRunner.hooks.before do |scenario|
  Runner.environment['TEST_KEY'] = 'TEST_VALUE' if scenario.name == 'Set variable'
end

