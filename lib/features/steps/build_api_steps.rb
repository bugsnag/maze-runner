Then("the request is valid for the Build API") do
  steps %Q{
    And the payload field "apiKey" equals "#{$api_key}"
    the payload field "appVersion" is not null
  }
end
Then("the request is valid for the Android Mapping API") do
  steps %Q{
    And the payload field "apiKey" equals "#{$api_key}"
    the payload field "proguard" is not null
    the payload field "appId" is not null
    the payload field "versionCode" is not null
    the payload field "buildUUID" is not null
    the payload field "versionName" is not null
  }
end