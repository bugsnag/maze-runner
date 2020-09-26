# Configure app environment
bs_username = ENV['BROWSER_STACK_USERNAME']
bs_access_key = ENV['BROWSER_STACK_ACCESS_KEY']
bs_local_id = ENV['BROWSER_STACK_LOCAL_IDENTIFIER'] || 'maze_browser_stack_test_id'
bs_device = ENV['DEVICE_TYPE']
app_location = 'app/build/outputs/apk/release/app-release.apk'

$api_key = '12312312312312312312312312312312'

ENV['BUGSNAG_API_KEY'] = $api_key

AfterConfiguration do |config|
  ResilientDriver.new(bs_username, bs_access_key, bs_local_id, bs_device, app_location)
  MazeRunner.driver.start_driver unless MazeRunner.configuration.appium_session_isolation
end

After do
  MazeRunner.driver.reset_with_timeout unless MazeRunner.configuration.appium_session_isolation
end

at_exit do
  MazeRunner.driver.driver_quit unless MazeRunner.configuration.appium_session_isolation
end
