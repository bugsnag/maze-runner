# Configure app environment
require 'pp'

bs_username = ENV['BROWSER_STACK_USERNAME']
bs_access_key = ENV['BROWSER_STACK_ACCESS_KEY']
bs_local_id = ENV['BROWSER_STACK_LOCAL_IDENTIFIER'] || 'maze_browser_stack_test_id'
bs_device = 'ANDROID_9'
app_location = 'app/build/outputs/apk/release/app-release.apk'

pp "Beginning of envs"
pp bs_username
pp bs_access_key
pp "End of envs"

AfterConfiguration do |config|
  $driver = AppAutomateDriver.new(bs_username, bs_access_key, bs_local_id)
  $driver.start_driver(bs_device, app_location)
end