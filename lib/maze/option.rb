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
    TEST_DEVICE = 'device'
    TEST_BROWSER = 'browser'

    # BrowserStack-only options
    BS_LOCAL = 'bs-local'
    USERNAME = 'username'
    ACCESS_KEY = 'access-key'
    # TODO: Rename to be farm agnostic
    BS_APPIUM_VERSION = 'appium-version'

    # Sauce Labs-only options
    SL_LOCAL = 'sl-local'

    # Local-only options
    OS = 'os'
    OS_VERSION = 'os-version'
    APPIUM_SERVER = 'appium-server'
    START_APPIUM = 'start-appium'
    APPLE_TEAM_ID = 'apple-team-id'
    UDID = 'udid'

    # Logging options
    LOG_REQUESTS = 'log-requests'
  end
end
