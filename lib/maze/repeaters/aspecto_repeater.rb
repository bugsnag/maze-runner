module Maze
  module Repeaters
    # Repeats Bugsnag requests
    class AspectoRepeater < RequestRepeater

      private

      def set_headers(request)
        # TODO Also overwrite apiKey in the payload, if present, recalculate the integrity header (handling
        #   compressed payloads if the content-encoding header is set accordingly)
        request['Authorization'] = Maze.config.aspecto_repeater_api_key
      end

      def enabled?
        # enabled if the config option is on and this request type should be repeated
        Maze.config.aspecto_repeater_api_key && url_for_request_type
      end

      def url_for_request_type
        url = case @request_type
              when :traces then 'https://otelcol.aspecto.io:4318/v1/traces'
              else return nil
              end
        URI.parse(url)
      end
    end
  end
end
