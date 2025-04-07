module Maze
  module Api
    class ExitCode
      # Cucumber itself can use codes 0 to 2

      AUTOMATION_GENERIC_ERROR = 10
      AUTOMATION_ELEMENT_NOT_FOUND = 11
      AUTOMATION_TIMEOUT = 12
      AUTOMATION_STALE_ELEMENT = 13

      SIGTERM = 20

      APP_UPLOAD_FAILURE = 100
      TUNNEL_FAILURE = 101
      SESSION_CREATION_FAILURE = 102
      APPIUM_SESSION_FAILURE = 103
      # A catch-all for certain errors related to Appium failures when the app is running app hang or ANR tests
      APPIUM_APP_HANG_FAILURE = 104
    end
  end
end
