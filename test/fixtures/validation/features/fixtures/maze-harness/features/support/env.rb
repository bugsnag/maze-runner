Maze.config.enforce_bugsnag_integrity = false

pp "Current validator scenario is: #{ENV['VALIDATOR_SCENARIO']}"

case ENV['VALIDATOR_SCENARIO']
when 'pass'
  Maze.config.add_validator('error') do |validator|
    validator.regex_comparison('string', /[fobar]{6}/)
    validator.element_int_in_range('number', 100..200)
    validator.element_a_greater_or_equal_element_b('hash.val2', 'hash.val1')
  end
when 'fail'
  Maze.config.add_validator('error') do |validator|
    validator.regex_comparison('string', /[fobr]{6}/)
    validator.element_int_in_range('number', 100..110)
    validator.element_a_greater_or_equal_element_b('hash.val1', 'hash.val2')
  end
when 'empty'
  Maze.config.add_validator('error') do |validator|
  end
when 'error'
  Maze.config.add_validator('error') do |validator|
    raise 'An error occurred in the validator'
  end
when 'custom_fail'
  Maze.config.add_validator('error') do |validator|
    if Maze::Helper.read_key_path(validator.body, 'string') == 'foobar'
      validator.success = false
      validator.errors << 'The string should not be "foobar"'
    end
  end
when 'trace'
  Maze.config.add_validator('trace') do |validator|
    validator.regex_comparison('string', /[fobar]{6}/)
    validator.element_int_in_range('number', 100..200)
    validator.element_a_greater_or_equal_element_b('hash.val2', 'hash.val1')
  end
end
