module Maze
  module Repeaters
    # Repeats Bugsnag requests
    class HubRepeater < RequestRepeater

      private

      def set_headers(request)
        request['bugsnag-api-key'] = Maze.config.hub_repeater_api_key
      end

      def enabled?
        # enabled if the config option is on and this request type should be repeated
        Maze.config.hub_repeater_api_key && url_for_request_type
      end

      def url_for_request_type
        url = case @request_type
              when :errors then 'https://notify.insighthub.smartbear.com/'
              when :sessions then 'https://sessions.insighthub.smartbear.com/'
              when :traces then "https://#{Maze.config.hub_repeater_api_key}.otlp.insighthub.smartbear.com/v1/traces"
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
