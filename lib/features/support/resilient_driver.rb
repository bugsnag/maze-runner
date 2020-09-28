require 'appium_lib'
require_relative './fast_selenium'
require_relative './logger'

# Handles Appium driver restarts and retries in the case of failure
class ResilientAppiumDriver < AppAutomateDriver
  
  # Checks for an element, waiting until it is present or the method times out
  #
  # @param element_id [String] the element to search for using the @element_locator strategy
  # @param timeout [Integer] the maximum time to wait for an element to be present in seconds
  # @param retry_if_stale [Boolean] enables the method to retry acquiring the element if a StaleObjectException occurs
  def wait_for_element(element_id, timeout = 15, retry_if_stale = true)
    super
  rescue Selenium::WebDriver::Error::UnknownError, Selenium::WebDriver::Error::WebDriverError
    recover { wait_for_element element_id, timeout, retry_if_stale }
  end

  # Resets the app
  def reset
    $logger.info 'Resetting app'
    super
  rescue Selenium::WebDriver::Error::UnknownError, Selenium::WebDriver::Error::WebDriverError
    recover { reset }
  end

  # Clicks a given element
  #
  # @param element_id [String] the element to click using the @element_locator strategy
  def click_element(element_id)
    super
  rescue Selenium::WebDriver::Error::UnknownError, Selenium::WebDriver::Error::WebDriverError
    recover { click_element element_id }
  end

  # Clears a given element
  #
  # @param element_id [String] the element to clear, found using the @element_locator strategy
  def clear_element(element_id)
    super
  rescue Selenium::WebDriver::Error::UnknownError, Selenium::WebDriver::Error::WebDriverError
    recover { clear_element element_id }
  end

  # Sends keys to a given element
  #
  # @param element_id [String] the element to send text to using the @element_locator strategy
  # @param text [String] the text to send
  def send_keys_to_element(element_id, text)
    super
  rescue Selenium::WebDriver::Error::UnknownError, Selenium::WebDriver::Error::WebDriverError
    recover { send_keys_to_element element_id, text }
  end

  # Sends keys to a given element, clearing it first
  #
  # @param element_id [String] the element to clear and send text to using the @element_locator strategy
  # @param text [String] the text to send
  def clear_and_send_keys_to_element(element_id, text)
    super
  rescue Selenium::WebDriver::Error::UnknownError, Selenium::WebDriver::Error::WebDriverError
    recover { clear_and_send_keys_to_element element_id, text }
  end

  # Reset the currently running application after a given timeout
  #
  # @param timeout [Number] the amount of time in seconds to wait before resetting
  def reset_with_timeout(timeout=0.1)
    super
  rescue Selenium::WebDriver::Error::UnknownError, Selenium::WebDriver::Error::WebDriverError
    recover { reset_with_timeout timeout }
  end

  # Wraps @see Appium::Device#background_app
  def background_app(timeout)
    super
  rescue Selenium::WebDriver::Error::UnknownError, Selenium::WebDriver::Error::WebDriverError
    recover { background_app timeout }
  end

  # Wraps @see Appium::Device#close_app
  def close_app
    super
  rescue Selenium::WebDriver::Error::UnknownError, Selenium::WebDriver::Error::WebDriverError
    recover { close_app }
  end

  # Wraps @see Appium::Device#launch_app
  def launch_app
    super
  rescue Selenium::WebDriver::Error::UnknownError, Selenium::WebDriver::Error::WebDriverError
    recover { launch_app }
  end

  # Restarts the underlying driver and calls the block given.
  def recover
    # BrowserStack's iOS 10 and 11 iOS devices seemed prone to the underlying Appium connection failing.
    # There is potential for an infinite loop here, but in reality a single restart seems
    # sufficient each time the error occurs.  CI step timeouts are also in place to guard
    # against an infinite loop.
    $logger.warn 'Appium Error occurred - restarting driver.'
    restart
    sleep 5 # Only to avoid a possible tight loop
    yield
  end
end
