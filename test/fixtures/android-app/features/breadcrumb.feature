Feature: Android support

Scenario: Manual Filter Tracking
    When I run "ManualFilterScenario" with the defaults
    Then I should receive a request
    And the request is a valid for the error reporting API
    And the "Bugsnag-API-Key" header equals "a35a2a72bd230ac0aa0f52715bbdc6aa"
    And the exception "message" equals "ManualFilterScenario"
    And the event "breadcrumbs" is not null
    And the event "metaData.custom.bar" equals "FIXME"

#    TODO following:
#default (onPause)
#Bugsnag.leaveBreadcrumb("Hello Breadcrumb!")
#Bugsnag.leaveBreadcrumb("Another Breadcrumb", BreadcrumbType.USER, Collections.singletonMap("Foo", "Bar"))