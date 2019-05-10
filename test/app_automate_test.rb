require 'test_helper'
require_relative '../lib/features/support/app-automate'

class AppAutomateTest < Test::Unit::TestCase

  USERNAME = "Username"
  ACCESS_KEY = "Access_key"
  LOCAL_ID = "Local_id"

  def test_default_assignments
    driver = AppAutomateDriver.new(USERNAME, ACCESS_KEY, LOCAL_ID)
    assert_equal(USERNAME, driver.instance_variable_get( :@username ))
    assert_equal(ACCESS_KEY, driver.instance_variable_get( :@access_key ))
    assert_equal(LOCAL_ID, driver.instance_variable_get( :@local_id ))
    assert_equal(:id, driver.instance_variable_get( :@locator ))
    assert_equal({
      'browserstack.console': 'errors',
      'browserstack.localIdentifier': LOCAL_ID,
      'browserstack.local': 'true'
    }, driver.instance_variable_get( :@capabilities ))
  end

  def test_overridden_locator
    driver = AppAutomateDriver.new(USERNAME, ACCESS_KEY, LOCAL_ID, :accessibility_id)
    assert_equal(:accessibility_id, driver.instance_variable_get( :@locator ))
  end
end
