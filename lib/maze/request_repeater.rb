module Maze
  # Repeats POST requests
  module RequestRepeater

    def do_POST(request, response)
      repeat(request) if enabled?

      super(request, response)
    end

    private

    def enabled?
      # enabled if the config option is on and this request type should be repeated
      Maze.config.repeater_api_key && url_for_request_type
    end

    # @param request [HTTPRequest] The request to be repeated
    def repeat(request)

      # TODO: Forwarding of internal errors to be considered later
      return if request.header.keys.any? { |key| key.downcase == 'bugsnag-internal-error' }

      url = url_for_request_type
      http = Net::HTTP.new(url.host)
      bugsnag_request = Net::HTTP::Post.new(url.path)
      bugsnag_request['Content-Type'] = 'application/json'

      # Set all Bugsnag headers that are present
      bugsnag_request.body = request.body
      request.header.each {|key,value| bugsnag_request[key] = value if key.downcase.start_with? 'bugsnag-' }
      bugsnag_request['bugsnag-api-key'] = Maze.config.repeater_api_key

      # TODO Also overwrite apiKey in the payload, if present, and recalculate the integrity header

      http.request(bugsnag_request)
    end

    def url_for_request_type
      url = case @request_type
            when :errors then 'https://notify.bugsnag.com/'
            when :sessions then 'https://sessions.bugsnag.com/'
            when :traces then 'https://otlp.bugsnag.com/v1/traces'
            end
      URI.parse(url) if url
    end
  end
end
