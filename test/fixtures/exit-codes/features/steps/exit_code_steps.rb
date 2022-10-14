When('I set up the maze-harness console') do
  steps %{
    Given I start a new shell
    And I input "cd features/fixtures/maze-harness" interactively
    And I input "bundle install" interactively
    And I wait for the shell to output a match for the regex "Bundle complete!" to stdout
  }
end