Given("I raise {string}") do |error_type|
  error = get_error_from_type(error_type)
  raise error
end

Given("I set the exit code to {int}") do |exit_code|
  Maze::Hooks::ErrorCodeHook.exit_code = exit_code
end

def get_error_from_type(error_type)
  case error_type
  when 'Selenium::WebDriver::Error::UnknownError'
    Selenium::WebDriver::Error::UnknownError.new
  when 'Maze::Error::AppiumElementNotFoundError'
    Maze::Error::AppiumElementNotFoundError.new
  when 'Selenium::WebDriver::Error::TimeoutError'
    Selenium::WebDriver::Error::TimeoutError.new
  when 'RuntimeError'
    RuntimeError.new
  else
    $logger.error("Error type #{error_type} is not acceptable!")
  end
end
