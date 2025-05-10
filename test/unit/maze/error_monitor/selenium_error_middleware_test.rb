require_relative '../../test_helper'
require_relative '../../../../lib/maze/error_monitor/selenium_error_middleware'

class SeleniumErrorMiddlewareTest < Test::Unit::TestCase

  def setup
    @middleware = Maze::ErrorMonitor::SeleniumErrorMiddleware.new(nil)
  end

  def test_sanitise_1
    plain = "An unknown server-side error occurred while processing the command. Original error: 'com.bugsnag.mazeracer' is still running after 500ms timeout"
    sanitised = @middleware.sanitise(plain)

    assert_equal("An unknown server-side error occurred while processing the command. Original error: 'APP_NAME' is still running after 500ms timeout", sanitised)
  end

  def test_sanitise_2
    plain = "unexpected end of stream on http://10.7.50.187:64618/..."
    sanitised = @middleware.sanitise(plain)

    assert_equal("unexpected end of stream on URL", sanitised)
  end


end
