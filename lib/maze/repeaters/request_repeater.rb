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

        Net::HTTP.start(uri.host, uri.port, :use_ssl => true) do |https|
          onward_request = Net::HTTP::Post.new(uri)
          onward_request.body = decompress(request)

          # Set all headers that are present, unless Gzip is not supported
          request.header.each do |key,value|
            next if !gzip_supported && key.downcase == 'content-encoding'
            next if key.downcase.start_with? 'bugsnag'

            $logger.info "#{key} = #{value}"
            onward_request[key] = value
          end
          set_headers onward_request

          https.request(onward_request)
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
    end
  end
end
