# frozen_string_literal: true

# Provides the set of Maze Runner command line options
module Maze
  module Option
    # Document server options
    DS_BIND_ADDRESS = 'document-server-bind-address'
    DS_PORT = 'document-server-port'

    # Server options
    HTTPS = 'https'
    BIND_ADDRESS = 'bind-address'
    NULL_PORT = 'null-port'
    PORT = 'port'
    DS_ROOT = 'document-server-root'

    # Appium options
    A11Y_LOCATOR = 'a11y-locator'
    APP = 'app'
    CAPABILITIES = 'capabilities'
    FARM = 'farm'

    # Generic device farm options
    ACCESS_KEY = 'access-key'
    APP_ACTIVITY = 'app-activity'
    APP_BUNDLE_ID = 'app-bundle-id'
    APP_PACKAGE = 'app-package'
    APPIUM_VERSION = 'appium-version'
    BROWSER = 'browser'
    BROWSER_VERSION = 'browser-version'
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
    BUGSNAG_REPEATER_API_KEY = 'repeater-api-key'
    HUB_REPEATER_API_KEY = 'hub-repeater-api-key'
    BUGSNAG = 'bugsnag'
    RETRIES = 'retries'
  end
end
