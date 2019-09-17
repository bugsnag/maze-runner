require 'webrick'
require 'json'

# This port number is semi-arbitrary. It doesn't matter for the sake of
# the application what it is, but there are some constraints due to some
# of the environments that we know this will be used in – namely, driving
# remote browsers on BrowserStack. The ports/ranges that Safari will access
# on "localhost" urls are restricted to the following:
#
#   80, 3000, 4000, 5000, 8000, 8080 or 9000-9999
#   [ from https://stackoverflow.com/a/28678652 ]
#
MOCK_API_PORT = 9339

# Receives and parses the requests and payloads sent from the test fixture
class Servlet < WEBrick::HTTPServlet::AbstractServlet
  # Logs an incoming GET WEBrick request.
  #
  # @param request [HTTPRequest] The incoming GET request
  # @param response [HTTPResponse] The response to return
  def do_GET(request, response)
    log_request(request)
  end

  # Logs and parses an incoming POST request.
  # Parses `multipart/form-data` and `application/json` content-types.
  # Parsed requests are added to the Server.stored_requests Array.
  #
  # @param request [HTTPRequest] The incoming GET request
  # @param response [HTTPResponse] The response to return
  def do_POST(request, response)
    log_request(request)
    case request['Content-Type']
    when /^multipart\/form-data; boundary=([^;]+)/
      boundary = WEBrick::HTTPUtils::dequote($1)
      body = WEBrick::HTTPUtils.parse_form_data(request.body(), boundary)
      Server.stored_requests << {body: body, request: request}
    else
      # "content-type" is assumed to be JSON (which mimics the behaviour of
      # the actual API). This supports browsers that can't set this header for
      # cross-domain requests (IE8/9)
      Server.stored_requests << {body: JSON.load(request.body()), request:request}
    end
    response.header['Access-Control-Allow-Origin'] = '*'
    response.status = 200
  end

  # Logs and returns a set of valid headers for this servlet.
  #
  # @param request [HTTPRequest] The incoming GET request
  # @param response [HTTPResponse] The response to return
  def do_OPTIONS(request, response)
    log_request(request)
    response.header['Access-Control-Allow-Origin'] = '*'
    response.header['Access-Control-Allow-Methods'] = 'POST, OPTIONS'
    response.header['Access-Control-Allow-Headers'] = 'Origin,Content-Type,Bugsnag-Sent-At,Bugsnag-Api-Key,Bugsnag-Payload-Version,Accept'
    response.status = 200
  end

  private
  def log_request(request)
    $logger.debug "#{request.request_method} request received!"
    $logger.debug "URI: #{request.unparsed_uri}"
    $logger.debug "HEADERS: #{request.raw_header}"
    case request['Content-Type']
    when /^multipart\/form-data; boundary=([^;]+)/
      boundary = WEBrick::HTTPUtils::dequote($1)
      body = WEBrick::HTTPUtils.parse_form_data(request.body(), boundary)
      $logger.debug "BODY: #{JSON.pretty_generate(body)}"
    else
      $logger.debug "BODY: #{JSON.pretty_generate(JSON.load(request.body))}"
    end
  end
end

# Receives and stores requests through a WEBrick HTTPServer
class Server
  class << self
    # Whether the server thread is running
    #
    # @return [Boolean] If the server is running
    def is_running?
      @thread and @thread.alive?
    end

    # An array of requests received.
    # Each request is hash consisting of:
    #   body: The parsed body of the request
    #   request: The original HTTPRequest object
    #
    # @return [Array] An array of received requests
    def stored_requests
      @requests ||= []
    end

    # The first request received by the server.
    #
    # @return [Hash|nil] The first request
    def current_request
      stored_requests.first
    end

    # Starts the WEBrick server in a separate thread
    def start_server
      @thread = Thread.new do
        server = WEBrick::HTTPServer.new(
          :Port => MOCK_API_PORT,
          Logger: $logger,
          AccessLog: [],
        )
        server.mount '/', Servlet
        begin
          server.start
        ensure
          server.shutdown
        end
      end
    end

    # Stops the WEBrick server thread if it's running
    def stop_server
      @thread.kill if @thread and @thread.alive?
      @thread = nil
    end
  end
end

# Before all tests
Server.start_server

# After all tests
at_exit do
  Server.stop_server
end

# Before each test
Before do
  Server.stored_requests.clear
  unless Server.is_running?
    $logger.fatal "Mock server is not running on #{MOCK_API_PORT}"
    exit(1)
  end
end