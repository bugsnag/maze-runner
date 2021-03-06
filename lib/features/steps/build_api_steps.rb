# frozen_string_literal: true

# @!group Build API Steps

# Tests whether the top-most payload is valid for the Bugsnag build API
# APIKey fields and headers are tested against the '$api_key' global variable
Then('the build is valid for the Build API') do
  steps %(
    And the build payload field "apiKey" equals "#{$api_key}"
    And the build payload field "appVersion" is not null
  )
end

# Tests whether the top-most payload is valid for the Android mapping API
# APIKey fields and headers are tested against the '$api_key' global variable
Then('the build is valid for the Android Mapping API') do
  steps %(
    And the build payload field "apiKey" equals "#{$api_key}"
    And the build payload field "proguard" is not null
    And the build payload field "appId" is not null
    And the build payload field "versionCode" is not null
    And the build payload field "buildUUID" is not null
    And the build payload field "versionName" is not null
  )
end
