module Maze
  module ErrorMonitor
    class SeleniumErrorMiddleware

      def initialize(middleware)
        @middleware = middleware
      end

      def call(report)
        first_ex = report.raw_exceptions.first
        if first_ex.class.name.start_with?('Selenium::WebDriver')
          report.grouping_hash = first_ex.class.name.to_s + sanitise(first_ex.message.to_s)
        end

        @middleware.call(report)
      end

      def sanitise(message)
        regexes = [
          {
            pattern: /(An unknown server-side error occurred while processing the command. Original error: ')(.*)(' is still running after 500ms timeout)/,
            replacement: '\1APP_NAME\3'
          },
          {
            pattern: /(unexpected end of stream on )(http:\/\/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}:[0-9]{1,5}\/\.\.\.)/,
            replacement: '\1URL'
          },
          {
            pattern: /(Could not find a connected Android device in )([0-9]+)ms/,
            replacement: '\1TIME'
          }
        ]

        regex = regexes.find{|r| message =~ r[:pattern]}
        if regex
          message.gsub(regex[:pattern], regex[:replacement])
        else
          message
        end
      end
    end
  end
end
