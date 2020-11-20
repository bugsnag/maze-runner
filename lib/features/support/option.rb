# frozen_string_literal: true

# Provides the set of Maze Runner command line options
class Option
  # Common options
  SEPARATE_SESSIONS ||= 'separate-sessions'
  FARM ||= 'farm'
  APP ||= 'app'
  A11Y_LOCATOR ||= 'a11y-locator'
  RESILIENT ||= 'resilient'

  # BrowserStack-only options
  BS_LOCAL ||= 'bs-local'
  BS_DEVICE ||= 'device'
  USERNAME ||= 'username'
  ACCESS_KEY ||= 'access-key'
  BS_APPIUM_VERSION ||= 'appium-version'

  # Local-only options
  OS ||= 'os'
  OS_VERSION ||= 'os-version'
  APPIUM_SERVER ||= 'appium-server'
  APPLE_TEAM_ID ||= 'apple-team-id'
  UDID ||= 'udid'
end
