# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../lib/maze/client/appium/bs_devices'
require_relative '../../lib/maze/client/appium/bb_devices'

class DevicesTest < Test::Unit::TestCase

  def test_os_version
    # Ensure that every entry in the hash has a meaningful OS version
    Maze::Client::Appium::BrowserStackDevices::DEVICE_HASH.each do |key, value|
      platform_version = value['platformVersion']
      regex = /^[1-9][0-9]*(\.[0-9])?/
      assert_match(regex, platform_version) unless %w(sl_android sl_ios).include?(key)
    end
  end
end
