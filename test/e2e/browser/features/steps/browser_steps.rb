require 'socket'

def get_maze_runner_url
  protocol = Maze.config.https ? 'https' : 'http'
  if Maze.config.aws_public_ip
      "#{protocol}://#{Maze.public_address}"
  else
    "#{protocol}://#{get_private_hostname}:#{Maze.config.port}"
  end
end

def get_private_hostname
  case Maze.config.farm
  when :local
    'localhost'
  when :bs
    'bs-local.com'
  else # :bb
    # Get the IP address of the local machine - this is the only way I could
    # find to make it work with Firefox, Chrome and Safari over the tunnel.
    addr_infos = Socket.ip_address_list.reject( &:ipv6? )
                                       .reject( &:ipv4_loopback? )
    address = addr_infos[0].ip_address
    $logger.info "Using IP address #{address} to reach Maze Runner"
    address
  end
end

When('I navigate to the test URL {string}') do |test_path|
  maze_address = get_maze_runner_url
  url = "#{maze_address}/docs#{test_path}?maze_address=#{CGI.escape(maze_address)}"
  step("I navigate to the URL \"#{url}\"")
end

When('the exception matches the {string} values for the current browser') do |fixture|
  err = get_error_message(fixture)
  steps %(
    And the exception "errorClass" equals "#{err['errorClass']}"
    And the exception "message" equals "#{err['errorMessage']}"
  )
  if err['lineNumber']
    step("the \"lineNumber\" of stack frame 0 equals #{err['lineNumber']}")
  end
  if err['columnNumber']
    step("the \"columnNumber\" of stack frame 0 equals #{err['columnNumber']}")
  end
  if err['file']
    step("the \"file\" of stack frame 0 ends with \"#{err['file']}\"")
  end
end

When('the test should run in this browser') do
  wait = Selenium::WebDriver::Wait.new(timeout: 10)
  wait.until {
    Maze.driver.find_element(id: 'bugsnag-test-should-run') &&
        Maze.driver.find_element(id: 'bugsnag-test-should-run').text != 'PENDING'
  }
  skip_this_scenario if Maze.driver.find_element(id: 'bugsnag-test-should-run').text == 'NO'
end

When('I let the test page run for up to {int} seconds') do |n|
  wait = Selenium::WebDriver::Wait.new(timeout: n)
  wait.until {
    Maze.driver.find_element(id: 'bugsnag-test-state') &&
        (
        Maze.driver.find_element(id: 'bugsnag-test-state').text == 'DONE' ||
            Maze.driver.find_element(id: 'bugsnag-test-state').text == 'ERROR'
        )
  }
  txt = Maze.driver.find_element(id: 'bugsnag-test-state').text
  Maze.check.equal('DONE', txt, "Expected #bugsnag-test-state text to be 'DONE'. It was '#{txt}'.")
end

Then('Maze Runner reports the current platform as {string}') do |platform|
  Maze.check.equal(platform, Maze::Helper.get_current_platform)
end
