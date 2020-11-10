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
    digests = check_digest request
    case request['Content-Type']
    when %r{^multipart/form-data; boundary=([^;]+)}
      boundary = WEBrick::HTTPUtils::dequote($1)
      body = WEBrick::HTTPUtils.parse_form_data(request.body, boundary)
      Server.stored_requests << {
        body: body,
        request: request,
        digests: digests
      }
    else
      # "content-type" is assumed to be JSON (which mimics the behaviour of
      # the actual API). This supports browsers that can't set this header for
      # cross-domain requests (IE8/9)
      Server.stored_requests << {
        body: JSON.parse(request.body),
        request: request,
        digests: digests
      }
    end
    response.header['Access-Control-Allow-Origin'] = '*'
    response.status = Server.status_code
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
    response.status = Server.status_code
  end

  private

  def log_request(request)
    $logger.debug "#{request.request_method} request received"
    $logger.debug "URI: #{request.unparsed_uri}"
    $logger.debug "HEADERS: #{request.raw_header}"
    return if request.body.nil?

    case request['Content-Type']
    when nil
      nil
    when %r{^multipart/form-data; boundary=([^;]+)}
      boundary = WEBrick::HTTPUtils.dequote(Regexp.last_match(1))
      body = WEBrick::HTTPUtils.parse_form_data(request.body, boundary)
      $logger.debug 'BODY:'
      LogUtil.log_hash(Logger::Severity::DEBUG, body)
    else
      $logger.debug "BODY: #{JSON.pretty_generate(JSON.parse(request.body))}"
    end
  end

  def check_digest(request)
    header = request['Bugsnag-Integrity']
    return if header.nil?

    # Header must have type and digest
    parts = header.split ' '
    raise "Invalid Bugsnag-Integrity header: #{header}" unless parts.size == 2

    # Both digest types are stored whatever
    sha1 = Digest::SHA1.hexdigest(request.body)
    simple = request.body.bytesize
    $logger.debug "DIGESTS computed: sha1=#{sha1} simple=#{simple}"

    # Check digests match
    case parts[0]
    when 'sha1'
      raise "Given sha1 #{parts[1]} does not match the computed #{sha1}" unless parts[1] == sha1
    when 'simple'
      raise "Given simple digest #{parts[1]} does not match the computed #{simple}" unless parts[1] == simple
    else
      raise "Invalid Bugsnag-Integrity digest type: #{parts[0]}"
    end

    {
      sha1: sha1,
      simple: simple
    }
  end
end


