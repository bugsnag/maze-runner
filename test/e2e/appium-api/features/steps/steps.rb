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

When('I get the device logs') do
  log_type = if Maze.config.device.include?('ANDROID')
               'logcat'
             else
               'syslog'
             end
  logs = Maze::Api::Appium::DeviceManager.new.get_log(log_type)
  $logger.info "#{logs.length} device logs entries returned"
end

