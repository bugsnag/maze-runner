When("I wait for the host {string} to open port {string}") do |host, port|
  Network.wait_for_port(host, port)
end
When("I open the URL {string}") do |url|
  begin
    open(url, &:read)
  rescue OpenURI::HTTPError
    $logger.debug $!.inspect
  end
end