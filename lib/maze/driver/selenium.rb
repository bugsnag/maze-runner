require 'selenium-webdriver'

module Maze
  module Drivers
    # Handles browser automation fundamentals
    class SeleniumDriver
      def initialize(selenium_url, capabilities)
        @driver = Selenium::WebDriver.for :remote,
                                          url: selenium_url,
                                          desired_capabilities: capabilities
      end

      def find_element(*args)
        @driver.find_element *args
      end

      def navigate
        @driver.navigate
      end

      # Quits the driver
      def driver_quit
        @driver.quit
      end

      # check if Selenium supports running javascript in the current browser
      def javascript?
        @driver.execute_script('return true')
      rescue Selenium::WebDriver::Error::UnsupportedOperationError
        false
      end

      # check if the browser supports local storage, e.g. safari 10 on browserstack
      # does not have working local storage
      def local_storage?
        # Assume we can use local storage if we aren't able to verify by running JavaScript
        return true unless javascript?

        @driver.execute_script <<-JAVASCRIPT
      try {
        window.localStorage.setItem('__localstorage_test__', 1234)
        window.localStorage.removeItem('__localstorage_test__')

        return true
      } catch (err) {
        return false
      }
        JAVASCRIPT
      end
    end
  end
end
