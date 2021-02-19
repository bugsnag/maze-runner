# frozen_string_literal: true

# MazeRunner configuration
class Configuration

  def initialize
    @appium_session_isolation = false
    @receive_requests_wait = 30
  end

  # Whether each scenario should have its own Appium session
  attr_accessor :appium_session_isolation

  # Maximum time in seconds to wait in the `I wait to receive {int} error(s)/session(s)/build(s)` steps
  attr_accessor :receive_requests_wait
end
