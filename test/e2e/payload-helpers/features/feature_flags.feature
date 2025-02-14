Feature: Test feature flag steps work

    Scenario: Verify no feature flags found
        When I send a "no_feature_flags" feature-flag request
        Then I wait to receive an error
        # No featureFlags key
        And the event has no feature flags
        # Empty featureFlags array
        And event 1 has no feature flags

    Scenario: Verify feature flag individual steps
        When I send an "verify_flags" feature-flag request
        Then I wait to receive an error
        # Feature flag with variant
        And the event contains the feature flag "ev_0_flag_var" with variant "foo"
        And event 1 contains the feature flag "ev_1_flag_var" with variant "bar"
        # Feature flag with no variant
        And the event contains the feature flag "ev_0_flag_no_var" with no variant
        And event 1 contains the feature flag "ev_1_flag_no_var" with no variant
        # Does not contain feature flag
        And the event does not contain the feature flag "ev_0_sir_not_appearing"
        And event 1 does not contain the feature flag "ev_1_sir_not_appearing"

    Scenario: Verify feature flags with table
        When I send a "verify_flags" feature-flag request
        Then I wait to receive an error
        And the event contains the following feature flags:
            | featureFlag      | variant |
            | ev_0_flag_var    | foo     |
            | ev_0_flag_no_var |         |
        And event 1 contains the following feature flags:
            | featureFlag      | variant |
            | ev_1_flag_var    | bar     |
            | ev_1_flag_no_var |         |
