When('I set up the testception wrapper') do
  steps %{
    Given I start a new shell
    And I input "cd features/fixtures/testception" interactively
    And I input "bundle install" interactively
    And I wait for the shell to output a match for the regex "Bundle complete!" to stdout
  }
end