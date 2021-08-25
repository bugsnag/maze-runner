# frozen_string_literal: true

# Provides the set of Maze Runner command line options
module Maze
  module Option
    # Document server options
    DS_BIND_ADDRESS = 'document-server-bind-address'
    DS_PORT = 'document-server-port'
    DS_ROOT = 'document-server-root'

    # Server options
    BIND_ADDRESS = 'bind-address'
    PORT = 'port'
    NULL_PORT = 'null-port'

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
    LIST_DEVICES = 'list-devices'
    APP_BUNDLE_ID = 'app-bundle-id'

    # CrossBrowserTesting/Bitbar options
    SB_LOCAL = 'sb-local'

    # BrowserStack-only options
    BS_LOCAL = 'bs-local'

    # Sauce Labs-only options
    SL_LOCAL = 'sl-local'

    # BitBar-only options
    BB_LOCAL = 'bb-local'
    TMS_URI = 'tms-uri'

    TMS_URI = 'tms-uri'
    TMS_TOKEN = 'tms-token'

    # Local-only options
    APPIUM_SERVER = 'appium-server'
    START_APPIUM = 'start-appium'
    APPIUM_LOGFILE = 'appium-logfile'
    APPLE_TEAM_ID = 'apple-team-id'
    UDID = 'udid'

    # Logging options
    FILE_LOG = 'file-log'
    LOG_REQUESTS = 'log-requests'
    ALWAYS_LOG = 'always-log'

    # Runtime options
    ENABLE_RETRIES = 'enable-retries'
    ENABLE_BUGSNAG = 'enable-bugsnag'
  end
end
