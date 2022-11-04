# frozen_string_literal: true

require 'zlib'
require 'stringio'

module Maze
  module Servlets

    # Receives and parses the requests and payloads sent from the test fixture
    class Servlet < BaseServlet
      # Constructor
      #
      # @param server [HTTPServer] WEBrick HTTPServer
      # @param request_type [Symbol] Request type that the servlet will receive
      def initialize(server, request_type)
        super server
        @request_type = request_type
        @requests = Server.list_for request_type
      end

      # Logs an incoming GET WEBrick request.
      #
      # @param request [HTTPRequest] The incoming GET request
      # @param _response [HTTPResponse] The response to return
      def do_GET(request, _response)
        log_request(request)
      end

      # Logs and parses an incoming POST request.
      # Parses `multipart/form-data` and `application/json` content-types.
      # Parsed requests are added to the requests list.
      #
      # @param request [HTTPRequest] The incoming GET request
      # @param response [HTTPResponse] The response to return
      def do_POST(request, response)
        log_request(request)
        content_type = request['Content-Type']
        content_encoding = request['Content-Encoding']
        if %r{^multipart/form-data; boundary=([^;]+)}.match(content_type)
          boundary = WEBrick::HTTPUtils::dequote($1)
          body = WEBrick::HTTPUtils.parse_form_data(request.body, boundary)
          hash = {
            body: body,
            request: request
          }
        elsif %r{^gzip$}.match(content_encoding)
          gz_element = Zlib::GzipReader.new(StringIO.new(request.body))
          hash = {
            body: JSON.parse(gz_element.read),
            request: request
          }
        else
          # "content-type" is assumed to be JSON (which mimics the behaviour of
          # the actual API). This supports browsers that can't set this header for
          # cross-domain requests (IE8/9)
          digests = check_digest request
          hash = {
            body: JSON.parse(request.body),
            request: request,
            digests: digests
          }
        end
        @requests.add(hash)

        # For the response, delaying if configured to do so
        response_delay_ms = Server.response_delay_ms
        if response_delay_ms.positive?
          $logger.info "Waiting #{response_delay_ms} milliseconds before responding"
          sleep response_delay_ms / 1000.0
        end
        response.header['Access-Control-Allow-Origin'] = '*'
        response.status = Server.status_code('POST')
      rescue JSON::ParserError => e
        msg = "Unable to parse request as JSON: #{e.message}"
        if Maze.config.captured_invalid_requests.include? @request_type
          $logger.error msg
          Server.invalid_requests.add({
            reason: msg,
            request: request,
            body: request.body
          })
        else
          $logger.warn msg
        end
      rescue StandardError => e
        if Maze.config.captured_invalid_requests.include? @request_type
          $logger.error "Invalid request: #{e.message}"
          Server.invalid_requests.add({
            invalid: true,
            reason: e.message,
            request: {
              request_uri: request.request_uri,
              header: request.header,
              body: request.inspect
            }
          })
        else
          $logger.warn "Invalid request: #{e.message}"
        end
      end

      # Logs and returns a set of valid headers for this servlet.
      #
      # @param request [HTTPRequest] The incoming GET request
      # @param response [HTTPResponse] The response to return
      def do_OPTIONS(request, response)
        super

        response.header['Access-Control-Allow-Methods'] = 'POST, OPTIONS'
        response.status = Server.status_code('OPTIONS')
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
        when %r{^application/json$}
          $logger.debug "BODY: #{JSON.pretty_generate(JSON.parse(request.body))}"
        else
          $logger.debug "BODY: #{request.body}"
        end
      end

      # Checks the Bugsnag-Integrity header, if present, against the request and based on configuration.
      # If the header is present, if the digest must be correct.  However, the header need only be present
      # if configuration says so.
      def check_digest(request)
        header = request['Bugsnag-Integrity']
        if header.nil? && Maze.config.enforce_bugsnag_integrity
          raise 'Bugsnag-Integrity header must be present according to Maze.config.enforce_bugsnag_integrity'
        end
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
          raise "Given simple digest #{parts[1].inspect} does not match the computed #{simple.inspect}" unless parts[1].to_i == simple
        else
          raise "Invalid Bugsnag-Integrity digest type: #{parts[0]}"
        end

        {
          sha1: sha1,
          simple: simple
        }
      end
    end
  end
end
