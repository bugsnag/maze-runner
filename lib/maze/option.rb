# frozen_string_literal: true

# Provides the set of Maze Runner command line options
module Maze
  module Option
    # Server options
    BIND_ADDRESS = 'bind-address'
    PORT = 'port'

    # Appium options
    SEPARATE_SESSIONS = 'separate-sessions'
    FARM = 'farm'
    APP = 'app'
    A11Y_LOCATOR = 'a11y-locator'
    RESILIENT = 'resilient'
    CAPABILITIES = 'capabilities'

    # Generic device farm options
    USERNAME = 'username'
    ACCESS_KEY = 'access-key'
    APPIUM_VERSION = 'appium-version'
    DEVICE = 'device'
    BROWSER = 'browser'
    OS = 'os'
    OS_VERSION = 'os-version'

    # BrowserStack-only options
    BS_LOCAL = 'bs-local'

    # Sauce Labs-only options
    SL_LOCAL = 'sl-local'

    # Local-only options
    APPIUM_SERVER = 'appium-server'
    START_APPIUM = 'start-appium'
    APPIUM_LOGFILE = 'appium-logfile'
    APPLE_TEAM_ID = 'apple-team-id'
    UDID = 'udid'

    # Logging options
    LOG_REQUESTS = 'log-requests'
  end
end
