# frozen_string_literal: true

require 'test_helper'
require_relative '../lib/features/support/resilient_driver'
require_relative '../lib/features/support/app_automate_driver'

class ResilientAppiumDriverTest < Test::Unit::TestCase

  USERNAME = 'Username'
  ACCESS_KEY = 'Access_key'
  LOCAL_ID = 'Local_id'
  TARGET_DEVICE = 'ANDROID_9'
  APP_LOCATION = 'app_location'

  def test_initialize
    mock_driver = mock('app_automate_driver')
    AppAutomateDriver.stubs(:new).with(USERNAME,
                                       ACCESS_KEY,
                                       LOCAL_ID,
                                       TARGET_DEVICE,
                                       APP_LOCATION,
                                       :accessibility_id,
                                       {}).returns(mock_driver)

    resilient_driver = ResilientAppiumDriver.new(USERNAME, ACCESS_KEY, LOCAL_ID, TARGET_DEVICE, APP_LOCATION, :accessibility_id)

    assert_kind_of(ResilientAppiumDriver, MazeRunner.driver)
    assert_same(resilient_driver, MazeRunner.driver)
  end
end


