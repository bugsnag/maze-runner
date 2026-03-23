Feature: Using the document server

  Scenario: Serve content
    When I run the script "features/scripts/get_and_post.sh"
    Then I wait to receive an error
    And the error payload body matches the JSON fixture in "features/fixtures/payload.json"

  Scenario: Reflective requests with the main mock server
    When I start a timer
    And I make a reflective "GET" request on port "9339" with status "202" and delay of "2000"
    Then the status code for the last reflective request was "202"
    And at least 2000 ms have passed

    And I start a timer
    And I make a reflective "POST" request on port "9339" with status "567" and delay of "2000"
    Then the status code for the last reflective request was "567"
    And at least 2000 ms have passed

    And I start a timer
    And I make a reflective "POST-WITH-QUERY" request on port "9339" with status "418" and delay of "2000"
    Then the status code for the last reflective request was "418"
    And at least 2000 ms have passed