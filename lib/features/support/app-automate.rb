require 'appium_lib'
require_relative './driver'

class AppAutomateDriver < Driver

  attr_reader :device_type

  APP_UPLOAD_URI = "https://api-cloud.browserstack.com/app-automate/upload"

  def initialise(username, access_key, local_id, locator=:id)
    super(username, access_key, local_id)
    @locator = locator
  end

  def devices
    Devices::DEVICE_HASH
  end

  def start_driver(target_device, app_location)
    @device_type = target_device
    upload_app(app_location)
    start_local_tunnel
    @capabilities.merge! devices[target_device]
    @driver = Appium::Driver.new({
      'caps' => @capabilities,
      'appium_lib' => {
        :server_url => "http://#{@username}:#{@access_key}@hub-cloud.browserstack.com/wd/hub"
      }
    }, false).start_driver
  end

  def upload_app(app_location)
    res = `curl -u "#{@username}:#{@access_key}" -X POST "#{APP_UPLOAD_URI}" -F "file=@#{app_location}"`
    resData = JSON.parse(res)
    if resData.include?('error')
      raise Exception.new("BrowserStack upload failed due to error: #{resData['error']}")
    else
      @capabilities['app'] = resData['app_url']
    end
  end

  def wait_for_element(id, timeout=15)
    unless @driver.nil?
      wait = Selenium::WebDriver::Wait.new(:timeout => timeout)
      wait.until { @driver.find_element(@locator, accessibility_id).displayed? }
    end
  end

  def click_element(element_id)
    @driver.find_element(@locator, element_id).click unless @driver.nil?
  end

  def background_app(timeout=3)
    @driver.background_app(timeout) unless @driver.nil?
  end

  def reset_app
    @driver.reset unless @driver.nil?
  end
end
