module Maze
  module Repeaters
    # Repeats POST requests
    class RequestRepeater

      def initialize(request_type)
        @request_type = request_type
      end

      # @param request [HTTPRequest] The request to be repeated
      def repeat(request)

        return unless enabled?

        # TODO Forwarding of internal errors to be considered later
        return if request.header.keys.any? { |key| key.downcase == 'bugsnag-internal-error' }

        uri = url_for_request_type

        Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.to_s.start_with?('https')) do |https|

          uri.path = '/' if uri.path.nil? || uri.path.empty?

          onward_request = Net::HTTP::Post.new(uri.path)
          onward_request.body = decompress(request)

          # Set all headers that are present, unless Gzip is not supported
          request.header.each do |key,value|
            # Only include content-type header if gip is supported
            next if !gzip_supported && key.downcase == 'content-encoding'

            # All other headers are opt-in to avoid accidental leakage
            next unless include_header? key.downcase, value

            onward_request[key] = value
          end

          # Set headers specific to the repeater
          set_headers onward_request

          response = https.request(onward_request)
          log_response response
        end
      end

      private

      def gzip_supported
        true
      end

      def decompress(request)
        if !gzip_supported && %r{^gzip$}.match(request['Content-Encoding'])

          reader = Zlib::GzipReader.new(StringIO.new(request.body))
          reader.read
        else
          request.body
        end
      end

      def enabled?
        raise 'Method not implemented by this class'
      end

      def url_for_request_type
        raise 'Method not implemented by this class'
      end

      def include_header?(_key, _value)
        raise 'Method not implemented by this class'
      end

      def log_response(response)
        log "HEADERS:"
        response.header.each_header do |key, value|
          log "  #{key}: #{value}"
        end

        log
        log "BODY:"
        log response.body
      end
      
      def log(message = '')
        $logger.trace message
      end
    end
  end
end
