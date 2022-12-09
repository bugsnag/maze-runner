module Maze
  # Repeats POST requests
  class RequestRepeater

    # @param url [String] URL to repeat to including protocol, host and path
    def initialize(url)
      @url = URI.parse(url)
    end

    # @param request [HTTPRequest] The request to be repeated
    def repeat(request)

      # Do not forward internal errors
      return if request.header.keys.any? { |key| key.downcase == 'bugsnag-internal-error' }

      $logger.info "request.header.key?('Bugsnag-Api-Key'): #{request.header.key?('bugsnag-api-key')}"

      http = Net::HTTP.new(@url.host)
      bugsnag_request = Net::HTTP::Post.new(@url.path)
      bugsnag_request['Content-Type'] = 'application/json'

      # Set all Bugsnag headers that are present
      request.header.each {|key,value|
        $logger.info "#{key} = #{value}"
        bugsnag_request[key] = value if key.downcase.start_with? 'bugsnag-'
      }
      bugsnag_request['bugsnag-api-key'] = Maze.config.repeater_api_key
      # TODO Also overwrite apiKey in the payload, if present, and recalculate the integrity header

      bugsnag_request.body = request.body
      http.request(bugsnag_request)
    end
  end
end
