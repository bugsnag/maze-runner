Feature: Using the document server

  Scenario: Serve content
    When I run the script "features/scripts/get_and_post.sh"
    Then I wait to receive an error
    And the error payload body matches the JSON fixture in "features/fixtures/payload.json"
