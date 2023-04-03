Feature: Testing support on metrics endpoint

    Scenario: A basic metrics file is written
        # A sampling trace
        When I send a "metric-age"-type request
        And I send a "metric-shoeSize"-type request
