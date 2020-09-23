# frozen_string_literal: true

# MazeRunner configuration
class Configuration

  def initialize
    @appium_session_isolation = false
  end

  # Whether each scenario should have its own Appium session
  attr_accessor :appium_session_isolation
end
