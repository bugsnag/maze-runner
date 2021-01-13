# @!group Network steps

# Checks that a port on a given host is open and ready for connections.
#
# @step_input host [String] The host to check
# @step_input port [String] The port to check
When('I wait for the host {string} to open port {string}') do |host, port|
  Maze::Network.wait_for_port(host, port)
end

# Sets the HTTP status code to be used for all subsequent requests
#
# @step_input status_code [Integer] The status code to return
When('I set the HTTP status code to {int}') do |status_code|
  Maze::Server.status_code = status_code
end

# Sets the HTTP status code to be used for the next request
#
# @step_input status_code [Integer] The status code to return
When('I set the HTTP status code for the next request to {int}') do |status_code|
  Maze::Server.reset_status_code = true
  Maze::Server.status_code = status_code
end

# Attempts to open a URL.
#
# @step_input url [String] The URL to open.
When('I open the URL {string}') do |url|
  begin
    open(url, &:read)
  rescue OpenURI::HTTPError
    $logger.debug $!.inspect
  end
end
