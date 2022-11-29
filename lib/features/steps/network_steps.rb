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
  Maze::Server.set_status_code_generator(Maze::Generator.new [status_code].cycle)
end

# Sets the HTTP status code to be used for the next request
#
# @step_input status_code [Integer] The status code to return
When('I set the HTTP status code for the next request to {int}') do |status_code|
  Maze::Server.set_status_code_generator(create_defaulting_generator([status_code], Maze::Server::DEFAULT_STATUS_CODE))
end

# Sets the HTTP status code to be used for the next set of requests
#
# @step_input status_codes [String] A comma separated list of status codes to return
When('I set the HTTP status code for the next requests to {string}') do |status_codes|
  codes = status_codes.split(',').map(&:strip)
  Maze::Server.set_status_code_generator(create_defaulting_generator(codes, Maze::Server::DEFAULT_STATUS_CODE))
end

# Steps the HTTP status code to be used for all subsequent requests for a given connection type
#
# @step_input http_verb [String] The type of request this code will be used for
# @step_input status_code [Integer] The status code to return
When('I set the HTTP status code for {string} requests to {int}') do |http_verb, status_code|
  raise("Invalid HTTP verb: #{http_verb}") unless Maze::Server::ALLOWED_HTTP_VERBS.include?(http_verb)
  Maze::Server.set_status_code_generator(Maze::Generator.new([status_code].cycle), http_verb)
end

# Steps the HTTP status code to be used for the next request for a given connection type
#
# @step_input http_verb [String] The type of request this code will be used for
# @step_input status_code [Integer] The status code to return
When('I set the HTTP status code for the next {string} request to {int}') do |http_verb, status_code|
  raise("Invalid HTTP verb: #{http_verb}") unless Maze::Server::ALLOWED_HTTP_VERBS.include?(http_verb)
  Maze::Server.set_status_code_generator(create_defaulting_generator([status_code], Maze::Server::DEFAULT_STATUS_CODE), http_verb)
end

# Sets the sampling probability to be used for all subsequent trace responses
#
# @step_input sampling_probability [String] The sampling probability to return
When('I set the sampling probability to {string}') do |sampling_probability|
  Maze::Server.set_sampling_probability_generator(Maze::Generator.new [sampling_probability].cycle)
end

# Sets the sampling probability to be used for the next trace responses
#
# @step_input status_code [Integer] The status code to return
When('I set the sampling probability for the next trace to {string}') do |sampling_probability|
  Maze::Server.set_sampling_probability_generator(create_defaulting_generator([sampling_probability], Maze::Server::DEFAULT_SAMPLING_PROBABILITY))
end

# Sets the sampling probability to be used for the next set of trace requests
#
# @step_input sampling_probability [String] A comma separated list of values to use, with "null" used to omit the header
When('I set the sampling probability for the next traces to {string}') do |status_codes|
  codes = status_codes.split(',').map(&:strip)
  Maze::Server.set_sampling_probability_generator(create_defaulting_generator(codes, Maze::Server::DEFAULT_SAMPLING_PROBABILITY))
end

def create_defaulting_generator(codes, default)
  enumerator = Enumerator.new do |yielder|
    codes.each do |code|
      yielder.yield code
    end

    loop do
      yielder.yield default
    end
  end
  Maze::Generator.new enumerator
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
