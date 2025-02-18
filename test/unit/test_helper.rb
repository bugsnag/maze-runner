# frozen_string_literal: true

require 'test/unit'
require 'mocha/test_unit'
require 'timecop'

# Safe mode forces you to use Timecop with the block syntax since it always puts
# time back the way it was
# If you are running in safe mode and use Timecop without the block syntax
# `Timecop::SafeModeException` will be raised to tell the user they are not
# being safe.
# https://github.com/travisjeffery/timecop#timecopsafe_mode
Timecop.safe_mode = true
