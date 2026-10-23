# frozen_string_literal: true
 
# appium_lib_core 7.5.0 includes DriverExtensions::HasWebStorage, which Selenium removed in 4.30.

require 'selenium-webdriver'
 
module Selenium
  module WebDriver
    module DriverExtensions
      HasWebStorage = Module.new unless const_defined?(:HasWebStorage, false)
    end
  end
end