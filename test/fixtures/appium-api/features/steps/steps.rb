When('The app state is {string}') do |state|
  Maze.check.equal state.to_sym, Maze::Api::Appium::AppManager.new.state
end

When('I close the app') do
  Maze::Api::Appium::AppManager.new.close
end

When('I launch the app') do
  Maze::Api::Appium::AppManager.new.launch
end
