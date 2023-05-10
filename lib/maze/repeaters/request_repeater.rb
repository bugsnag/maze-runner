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

        url = url_for_request_type
        http = Net::HTTP.new(url.host)
        onward_request = Net::HTTP::Post.new(url.path)

        # Set all headers that are present
        onward_request.body = request.body
        request.header.each {|key,value| onward_request[key] = value }
        set_headers onward_request

        http.request(onward_request)
      end

      private

      def enabled?
        raise 'Method not implemented by this class'
      end

      def url_for_request_type
        raise 'Method not implemented by this class'
      end
    end
  end
end
