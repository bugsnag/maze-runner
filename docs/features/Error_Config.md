# Error Config support

## Endpoint

The `/error-config` endpoint is provided on the mock server for test fixtures to requests error configuration from.  Maze Runner stores any received requests for later inspection.

## Cucumber steps

Error configs can we added to an internal queue using the following step.  Error configs are removed from the queue when they are served.

```
When I prepare an error config with:
  | type     | name           | value                               |
  | header   | Cache-Control  | max-age=604800                      |
  | property | body           | @features/support/error_config.json |
  | property | status         | 200                                 |
```

- The `type` column can be either `header` or `property`. 
- If the `value` provided for `body` starts with `@` then Maze Runner will treat it as a file location to read the actual body from.

Properties of receive error config requests can be checked using the following steps:

```
the error config request {string} header equals {string}}
the error config request {string} query parameter equals {string}
```

(where `word` is `error config request` in this case).

## Example scenario

```Cucumber
  Scenario: Requesting an error config
    # Prepare the error config to be served
    When I prepare an error config with:
      | type     | name           | value                               |
      | header   | Cache-Control  | max-age=604800                      |
      | property | body           | @features/support/error_config.json |
      | property | status         | 200                                 |

    # Run the scenario that will request the error config
    Then I run "HandledJavaSmokeScenario"
    And I wait to receive an error
    And I wait for 1 error config to be requested

    # Check the error config request headers and parameters
    Then the error config request "Bugsnag-Api-Key" header equals "12312312312312312312312312312312"
    And the error config request "version" query parameter equals "1.2.3"
    And the error config request "versionCode" query parameter equals "123"
    And the error config request "releaseStage" query parameter equals "production"
    And the error config request "osVersion" query parameter equals "11"

    # Check the other outputs from the tst
    Then the error payload field "events" is an array with 1 elements
    And the exception "errorClass" equals "java.lang.IllegalStateException"
    # And so on ...
```