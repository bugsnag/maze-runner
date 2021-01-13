# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../lib/maze/devices'

class DevicesTest < Test::Unit::TestCase

  def test_os_version
    # Ensure that every entry in the hash has a meaningful OS version
    Maze::Devices::DEVICE_HASH.each do |key, value|
      os_version = value['os_version']
      regex = /^[1-9][0-9]*(\.[0-9])?/
      assert_match(regex, os_version)
    end
  end
end
