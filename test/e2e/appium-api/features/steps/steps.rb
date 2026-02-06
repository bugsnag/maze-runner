When('The app state is {string}') do |state|
  Maze.check.equal state.to_sym, Maze::Api::Appium::AppManager.new.state
end

When('I activate the app') do
  Maze::Api::Appium::AppManager.new.activate
end

When('I terminate the app') do
  Maze::Api::Appium::AppManager.new.terminate
end

When('I close the app') do
  Maze::Api::Appium::AppManager.new.close
end

When('I launch the app') do
  Maze::Api::Appium::AppManager.new.launch
end

When('I unlock the device') do
  Maze::Api::Appium::DeviceManager.new.unlock
end

When('I press the back button') do
  Maze::Api::Appium::DeviceManager.new.back
end

When('I set the device rotation to {string}') do |orientation|
  Maze::Api::Appium::DeviceManager.new.set_rotation(orientation.to_sym)
end

When('I execute the script {string}') do |command|
  Maze::Api::Appium::DeviceManager.new.execute_script(command)
end

When('I log the device info') do
  info = Maze::Api::Appium::DeviceManager.new.info
  $logger.info "Device info is: #{info}"
end

When('I list all available device log types') do
  manager = Maze::Api::Appium::DeviceManager.new
  log_types = manager.get_available_log_types
  $logger.info("Available log types: #{log_types}")
end

When('I get the {word} device logs') do |type|
  manager = Maze::Api::Appium::DeviceManager.new
  logs = manager.get_logs(type.to_sym)
  $logger.info "#{logs.length} entries returned for log type #{type}"

  # Write the logs to a file of the same name
  File.open("#{type}_logs.txt", 'w') do |file|
    logs.each do |entry|
      file.puts entry.to_s
    end
  end
end
