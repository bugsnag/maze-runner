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

# Steps the HTTP status code to be used for all subsequent requests for a given connection type
#
# @step_input http_verb [String] The type of request this code will be used for
# @step_input status_code [Integer] The status code to return
When('I set the HTTP status code for {string} requests to {int}') do |http_verb, status_code|
  allowed_verbs = ['OPTIONS', 'GET', 'POST', 'PUT', 'DELETE', 'HEAD', 'TRACE', 'PATCH', 'CONNECT']
  raise("Invalid HTTP verb: #{http_verb}") unless allowed_verbs.include?(http_verb)
  Maze::Server.status_override_verb = http_verb
  Maze::Server.status_code = status_code
end

# Steps the HTTP status code to be used for the next request for a given connection type
#
# @step_input http_verb [String] The type of request this code will be used for
# @step_input status_code [Integer] The status code to return
When('I set the HTTP status code for the next {string} request to {int}') do |http_verb, status_code|
  allowed_verbs = ['OPTIONS', 'GET', 'POST', 'PUT', 'DELETE', 'HEAD', 'TRACE', 'PATCH', 'CONNECT']
  raise("Invalid HTTP verb: #{http_verb}") unless allowed_verbs.include?(http_verb)
  Maze::Server.status_override_verb = http_verb
  Maze::Server.reset_status_code = true
  Maze::Server.status_code = status_code
end

# Sets the sampling probability to be used for all subsequent trace responses
#
# @step_input sampling_probability [String] The sampling probability to return
When('I set the sampling probability to {string}') do |sampling_probability|
  Maze::Server.sampling_probability = sampling_probability
end

# Sets the sampling probability to be used for the next trace responses
#
# @step_input status_code [Integer] The status code to return
When('I set the sampling probability for the next trace to {string}') do |sampling_probability|
  Maze::Server.reset_sampling_probability = true
  Maze::Server.sampling_probability = sampling_probability
end

# Sets the response delay to be used for all subsequent requests
#
# @step_input response_delay_ms [Integer] The delay in milliseconds
When('I set the response delay to {int} milliseconds') do |response_delay_ms|
  Maze::Server.response_delay_ms = response_delay_ms
end

# Sets the response delay to be used for the next request
#
# @step_input delay [Integer] The delay in milliseconds
When('I set the response delay for the next request to {int} milliseconds') do |delay|
  Maze::Server.reset_response_delay = true
  Maze::Server.response_delay_ms = delay
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

# Starts the terminating server to cancel requests received.
When('I start the terminating server') do
  Maze::TerminatingServer.start
end

# Sets the response message on the terminating server
When('I set the terminated response message to {string}') do |response_message|
  Maze::TerminatingServer.response = response_message
end

# Sets the maximum allowable amount of data received to the terminating server
#
# @step_input max_length [Integer] The number of bytes receivable
When('I set the terminating server data threshold to {int} bytes') do |max_length|
  Maze::TerminatingServer.max_received_size = max_length
end

# Check if a certain number of connections have been received by the terminating server
#
# @step_input request_count [Integer] The number of desired requests
Then('the terminating server has received {int} requests') do |request_count|
  Maze.check.equal(request_count, Maze::TerminatingServer.received_request_count,
    "#{request_count} terminated requests expected, #{Maze::TerminatingServer.received_request_count} received")
end
