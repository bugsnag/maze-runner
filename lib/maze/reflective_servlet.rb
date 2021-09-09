# frozen_string_literal: true

module Maze
  # Receives HTTP requests and responds according to the parameters given, which are:
  # - delay_ms - milliseconds to wait before responding
  # - status - HTTP response code
  # For GET requests these are expected to passed as GET parameters,
  # for POST requests they are expected to be given as JSON fields.
  class ReflectiveServlet < WEBrick::HTTPServlet::AbstractServlet

    # Accepts a GET request to provide a reflective response to.
    #
    # @param request [HTTPRequest] The incoming GET request
    # @param response [HTTPResponse] The response to return
    def do_GET(request, response)
      delay_ms = request.query['delay_ms']
      status = request.query['status']
      reflect response, delay_ms, status
    end

    # Accepts a POST request to provide a reflective response to.
    #
    # @param request [HTTPRequest] The incoming GET request
    # @param response [HTTPResponse] The response to return
    def do_POST(request, response)
      body = JSON.parse(request.body)
      delay_ms = body['delay_ms']
      status = body['status']

      reflect response, delay_ms, status
    rescue JSON::ParserError => e
      msg = "Unable to parse request as JSON: #{e.message}"
      $logger.error msg
      response.status = 418
    rescue StandardError => e
      $logger.error "Invalid request: #{e.message}"
      response.status = 500
    end

    def reflect(response, delay_ms, status)
      sleep delay_ms.to_i / 1000 unless delay_ms.nil?
      response.status = status || 200
      response.header['Access-Control-Allow-Origin'] = '*'
    end

    # Logs and returns a set of valid headers for this servlet.
    #
    # @param request [HTTPRequest] The incoming GET request
    # @param response [HTTPResponse] The response to return
    def do_OPTIONS(request, response)
      log_request(request)
      response.header['Access-Control-Allow-Origin'] = '*'
      response.header['Access-Control-Allow-Methods'] = 'POST, OPTIONS'
      response.header['Access-Control-Allow-Headers'] = %w[Accept
                                                           Bugsnag-Api-Key Bugsnag-Integrity
                                                           Bugsnag-Payload-Version
                                                           Bugsnag-Sent-At Content-Type
                                                           Origin].join(',')
    end

  end
end
