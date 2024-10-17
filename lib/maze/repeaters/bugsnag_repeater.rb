module Maze
  module Repeaters
    # Repeats Bugsnag requests
    class BugsnagRepeater < RequestRepeater

      private

      def set_headers(request)
        # TODO Also overwrite apiKey in the payload, if present, recalculate the integrity header (handling
        #   compressed payloads if the content-encoding header is set accordingly)
        request['bugsnag-api-key'] = Maze.config.bugsnag_repeater_api_key
      end

      def enabled?
        # enabled if the config option is on and this request type should be repeated
        Maze.config.bugsnag_repeater_api_key && url_for_request_type
      end

      def url_for_request_type
        traces_endpoint = URI.parse(ENV['MAZE_REPEATER_TRACES_ENDPOINT'] || 'https://otlp.bugsnag.com/v1/traces').tap do |u|
          u.host = "#{Maze.config.bugsnag_repeater_api_key}.#{u.host}" unless u.host == 'localhost'
        end
        url = case @request_type
              when :errors then ENV['MAZE_REPEATER_NOTIFY_ENDPOINT'] || 'https://notify.bugsnag.com/'
              when :sessions then ENV['MAZE_REPEATER_SESSIONS_ENDPOINT'] || 'https://sessions.bugsnag.com/'
              when :traces then traces_endpoint.to_s
              else return nil
              end
        URI.parse(url)
      end

      def include_header?(key, value)
        # Include all headers apart from the API key, which is set separately
        key != 'bugsnag-api-key'
      end
    end
  end
end
