MazeRunner.hooks.before do |scenario|
  STDOUT.puts '***** BEFORE: ' + scenario.name
  Runner.environment['TEST_KEY'] = 'TEST_VALUE' if scenario.name == 'Set variable'
end

