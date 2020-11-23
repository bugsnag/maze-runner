ENV["BUGSNAG_API_KEY"] = $api_key

AfterConfiguration do |_config|
  MazeRunner.config.enforce_bugsnag_integrity = false
end
