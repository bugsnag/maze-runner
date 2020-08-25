# frozen_string_literal: true

# Receives and parses the requests and payloads sent from the test fixture
class Servlet < WEBrick::HTTPServlet::AbstractServlet
  # Logs an incoming GET WEBrick request.
  #
  # @param request [HTTPRequest] The incoming GET request
  # @param _response [HTTPResponse] The response to return
  def do_GET(request, _response)
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
    when %r{^multipart/form-data; boundary=([^;]+)}
      boundary = WEBrick::HTTPUtils.dequote(Regexp.last_match(1))
      body = WEBrick::HTTPUtils.parse_form_data(request.body(), boundary)
      Server.stored_requests << { body: body, request: request }
    else
      # "content-type" is assumed to be JSON (which mimics the behaviour of
      # the actual API). This supports browsers that can't set this header for
      # cross-domain requests (IE8/9)
      Server.stored_requests << { body: JSON.parse(request.body),
                                  request: request }
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
    response.header['Access-Control-Allow-Headers'] =
      'Origin,Content-Type,Bugsnag-Sent-At,Bugsnag-Api-Key,Bugsnag-Payload-Version,Accept'
    response.status = 200
  end

  private

  def log_request(request)
    $logger.debug "#{request.request_method} request received!"
    $logger.debug "URI: #{request.unparsed_uri}"
    $logger.debug "HEADERS: #{request.raw_header}"
    return if request.body.nil?
    case request['Content-Type']
    when nil
      return
    when %r{^multipart/form-data; boundary=([^;]+)}
      boundary = WEBrick::HTTPUtils.dequote(Regexp.last_match(1))
      body = WEBrick::HTTPUtils.parse_form_data(request.body(), boundary)
      $logger.debug "BODY: #{JSON.pretty_generate(body)}"
    else
      $logger.debug "BODY: #{JSON.pretty_generate(JSON.parse(request.body))}"
    end
  end
end
