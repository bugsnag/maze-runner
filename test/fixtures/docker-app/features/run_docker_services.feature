Feature: Running docker services and commands

    Scenario: A service can be built and started
        When I start the service "sends_request"
        And I wait to receive an error
        Then the payload field "somedata" equals "data"
        And the exit code of the last docker command was 0
        And the last run docker command exited successfully
        And the last run docker command output "SOME OUTPUT"

    Scenario: A service can be started with a command
        When I run the service "sends_request" with the command "curl -F somedata=manual http://docker-tests:9339/notify"
        And I wait to receive an error
        Then the payload field "somedata" equals "manual"
        And the last run docker command exited successfully

    Scenario: A service can be started with a multiline command
        When I run the service "sends_request" with the command
        """
        curl -F somedata=multiline http://docker-tests:9339/notify
        curl -F somedata=multiline2 http://docker-tests:9339/notify
        """
        And I wait to receive 2 errors
        Then the payload field "somedata" equals "multiline"
        And I discard the oldest error
        And the payload field "somedata" equals "multiline2"
        And the last run docker command exited successfully

    Scenario: A services error status can be checked
        When I run the service "sends_request" with the command "/foo"
        Then the last run docker command did not exit successfully
