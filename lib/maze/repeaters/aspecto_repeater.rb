module Maze
  module Repeaters
    # Repeats Bugsnag requests
    class AspectoRepeater < RequestRepeater

      private

      def set_headers(request)
        request['Authorization'] = Maze.config.aspecto_repeater_api_key
      end

      def enabled?
        # enabled if the config option is on and this request type should be repeated
        Maze.config.aspecto_repeater_api_key && url_for_request_type
      end

      def gzip_supported
        false
      end

      def url_for_request_type
        url = case @request_type
              when :traces then 'https://otelcol.aspecto.io:4318/v1/traces'
              else return nil
              end
        URI.parse(url)
      end

      def include_header?(key, _value)
        true unless key.start_with? 'bugsnag'
      end
    end
  end
end
