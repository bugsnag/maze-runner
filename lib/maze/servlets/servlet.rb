# frozen_string_literal: true

require 'bugsnag'
require 'zlib'
require 'stringio'
require 'json_schemer'
require 'delegate'

module Maze
  class HttpRequest < SimpleDelegator
    def body
      @body ||= decode_body
    end

    private

    def decode_body
      delegate = __getobj__
      if %r{^gzip$}.match(delegate['Content-Encoding'])
        gz_element = Zlib::GzipReader.new(StringIO.new(delegate.body))
        gz_element.read
      else
        delegate.body
      end
    end
  end

  module Servlets

    # Receives and parses the requests and payloads sent from the test fixture
    class Servlet < BaseServlet

      # Constructor
      #
      # @param server [HTTPServer] WEBrick HTTPServer
      # @param request_type [Symbol] Request type that the servlet will receive
      # @param schema [Dictionary] A `json-schema` describing the payload for POST requests
      def initialize(server, request_type, schema=nil)
        super server
        @request_type = request_type
        @schema = JSONSchemer.schema(schema) unless schema.nil?
        @bugsnag_repeater = Maze::Repeaters::BugsnagRepeater.new(@request_type)
        @hub_repeater = Maze::Repeaters::HubRepeater.new(@request_type)
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

        @bugsnag_repeater.repeat request
        @hub_repeater.repeat request

        # Turn the WEBrick HttpRequest into our internal HttpRequest delegate
        request = Maze::HttpRequest.new(request)

        content_type = request['Content-Type']
        if %r{^multipart/form-data; boundary=([^;]+)}.match(content_type)
          boundary = WEBrick::HTTPUtils::dequote($1)
          body = WEBrick::HTTPUtils.parse_form_data(request.body, boundary)
          hash = {
            body: body,
            request: request,
            response: response
          }
        else
          # "content-type" is assumed to be JSON (which mimics the behaviour of
          # the actual API). This supports browsers that can't set this header for
          # cross-domain requests (IE8/9)
          digests = check_digest request
          hash = {
            body: JSON.parse(request.body),
            request: request,
            response: response,
            digests: digests
          }
        end
        if @schema
          schema_errors = @schema.validate(hash[:body])
          hash[:schema_errors] = schema_errors.to_a
        end
        add_request(hash)

        # For the response, delaying if configured to do so
        response_delay_ms = Server.response_delay_ms
        if response_delay_ms.positive?
          $logger.info "Waiting #{response_delay_ms} milliseconds before responding"
          sleep response_delay_ms / 1000.0
        end

        set_response_header response.header
        response.status = post_status_code
      rescue JSON::ParserError => e
        msg = "Unable to parse request as JSON: #{e.message}"
        if Maze.config.captured_invalid_requests.include? @request_type
          Bugsnag.notify e
          $logger.error msg
          Server.invalid_requests.add({
            reason: msg,
            request: request,
            response: response,
            body: request.body
          })
        else
          $logger.warn msg
        end
      rescue StandardError => e
        msg = "Invalid #{@request_type} request: #{e.message}"
        if Maze.config.captured_invalid_requests.include? @request_type
          Bugsnag.notify e
          $logger.error msg
          Server.invalid_requests.add({
            invalid: true,
            reason: e.message,
            request: {
              request_uri: request.request_uri,
              header: request.header,
              body: request.inspect
            },
            response: response
          })
        else
          $logger.warn msg
        end
      end

      def post_status_code
        if [:errors, :sessions, :builds, :uploads, :sourcemaps, :traces].include? @request_type
          Server.status_code('POST')
        else
          200
        end
      end

      def set_response_header(header)
        header['Access-Control-Allow-Origin'] = '*'
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

      def add_request(request)
        if @request_type == :errors and system_generated_anr?(request)
          $logger.info 'Ignoring system-generated ANR'
          Server.list_for('ignored').add(request)
        else
          Server.list_for(@request_type).add(request)
        end
      end

      def system_generated_anr?(request)
        body = request[:body]
        error_class = Maze::Helper.read_key_path(body, 'events.0.exceptions.0.errorClass')
        return false unless error_class == 'ANR'

        stack_trace = Maze::Helper.read_key_path(body, 'events.0.exceptions.0.stacktrace')
        return false unless stack_trace.kind_of?(Array)

        method_1 = stack_trace.any? { |frame| frame['method'] == 'android.os.BinderProxy.transact' }
        method_2 = stack_trace.any? { |frame| frame['method'] == 'android.app.IActivityManager$Stub$Proxy.handleApplicationCrash' }
        method_1 && method_2
      end

      def log_request(request)
        $logger.trace "#{request.request_method} request received"
        $logger.trace "URI: #{request.unparsed_uri}"
        $logger.trace "HEADERS: #{request.raw_header}"
        return if request.body.nil?

        case request['Content-Type']
        when nil
          nil
        when %r{^multipart/form-data; boundary=([^;]+)}
          boundary = WEBrick::HTTPUtils.dequote(Regexp.last_match(1))
          body = WEBrick::HTTPUtils.parse_form_data(request.body, boundary)
          $logger.trace 'BODY:'
          LogUtil.log_hash(Logger::Severity::TRACE, body)
        when %r{^application/json$}
          $logger.trace "BODY: #{JSON.pretty_generate(JSON.parse(request.body))}"
        else
          $logger.trace "BODY: #{request.body}"
        end
      end

      # Checks the Bugsnag-Integrity header, if present, against the request and based on configuration.
      # If the header is present, if the digest must be correct.  However, the header need only be present
      # if configuration says so.
      def check_digest(request)
        header = request['Bugsnag-Integrity']

        if header.nil? && Maze.config.enforce_bugsnag_integrity && %i[sessions errors traces].include?(@request_type)
          raise "Bugsnag-Integrity header must be present for #{@request_type} according to Maze.config.enforce_bugsnag_integrity"
        end
        return if header.nil?

        # Header must have type and digest
        parts = header.split ' '
        raise "Invalid Bugsnag-Integrity header: #{header}" unless parts.size == 2

        # Both digest types are stored whatever
        sha1 = Digest::SHA1.hexdigest(request.body)
        simple = request.body.bytesize
        $logger.trace "DIGESTS computed: sha1=#{sha1} simple=#{simple}"

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
