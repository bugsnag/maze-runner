# @!group Network steps

# Checks that a port on a given host is open and ready for connections.
#
# @step_input host [String] The host to check
# @step_input port [String] The port to check
When("I wait for the host {string} to open port {string}") do |host, port|
  Network.wait_for_port(host, port)
end

# Attempts to open a URL.
#
# @step_input url [String] The URL to open.
When("I open the URL {string}") do |url|
  begin
    open(url, &:read)
  rescue OpenURI::HTTPError
    $logger.debug $!.inspect
  end
end