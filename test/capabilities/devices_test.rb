# frozen_string_literal: true

require 'test_helper'
require_relative '../../lib/features/support/capabilities/devices'

class DevicesTest < Test::Unit::TestCase

  def test_os_version
    # Ensure that every entry in the hash has a meaningful OS version
    Devices::DEVICE_HASH.each do |key, value|
      os_version = value['os_version']
      regex = /^[1-9][0-9]*(\.[0-9])?/
      assert_match(regex, os_version)
    end
  end

end
