# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../lib/maze/../../lib/maze/browser_stack_devices'

class DevicesTest < Test::Unit::TestCase

  def test_os_version
    # Ensure that every entry in the hash has a meaningful OS version
    Maze::BrowserStackDevices::DEVICE_HASH.each do |key, value|
      os_version = value['os_version']
      regex = /^[1-9][0-9]*(\.[0-9])?/
      assert_match(regex, os_version) unless %w(sl_android sl_ios).include?(key)
    end
  end
end
