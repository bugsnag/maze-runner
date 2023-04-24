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
    NULL_PORT = 'null-port'
    PORT = 'port'

    # Appium options
    A11Y_LOCATOR = 'a11y-locator'
    APP = 'app'
    CAPABILITIES = 'capabilities'
    FARM = 'farm'

    # Generic device farm options
    ACCESS_KEY = 'access-key'
    APP_BUNDLE_ID = 'app-bundle-id'
    APPIUM_VERSION = 'appium-version'
    BROWSER = 'browser'
    DEVICE = 'device'
    LIST_DEVICES = 'list-devices'
    OS = 'os'
    OS_VERSION = 'os-version'
    TUNNEL = 'tunnel'
    USERNAME = 'username'
    APPIUM_SERVER = 'appium-server'
    SELENIUM_SERVER = 'selenium-server'

    # BitBar options
    SB_LOCAL = 'sb-local'

    # BrowserStack-only options
    BS_LOCAL = 'bs-local'

    # BitBar-only options
    TMS_URI = 'tms-uri'
    TMS_TOKEN = 'tms-token'

    # Local-only options
    APPIUM_LOGFILE = 'appium-logfile'
    APPLE_TEAM_ID = 'apple-team-id'
    START_APPIUM = 'start-appium'
    UDID = 'udid'

    # Logging options
    ALWAYS_LOG = 'always-log'
    FILE_LOG = 'file-log'
    LOG_REQUESTS = 'log-requests'

    # General options
    AWS_PUBLIC_IP = 'aws-public-ip'
    REPEATER_API_KEY = 'repeater-api-key'
    ENABLE_BUGSNAG = 'enable-bugsnag'
    ENABLE_RETRIES = 'enable-retries'
  end
end
