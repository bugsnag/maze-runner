# frozen_string_literal: true

require 'test_helper'
require_relative '../lib/maze/loggers/logger'

class LoggerTest < Test::Unit::TestCase
  def setup
    reset_logger!
  end

  def teardown
    reset_logger!
  end

  
  def test_it_logs_messages
    io = StringIO.new
    
    logger = Maze::Loggers::Logger.instance
    logger.level = Logger::DEBUG
    logger.reopen(io)
    
    io.rewind
    assert_empty(io.read)
    
    Timecop.freeze(Time.utc(2023, 1, 2, 3, 4, 5)) { logger.debug('hello') }
    Timecop.freeze(Time.utc(2023, 1, 2, 6, 7, 8)) { logger.info('hello') }
    Timecop.freeze(Time.utc(2023, 1, 2, 9, 10, 11)) { logger.warn('hello') }
    Timecop.freeze(Time.utc(2023, 1, 2, 12, 13, 14)) { logger.error('hello') }
    Timecop.freeze(Time.utc(2023, 1, 2, 15, 16, 17)) { logger.fatal('hello') }
    Timecop.freeze(Time.utc(2023, 1, 2, 18, 19, 20)) { logger.unknown('hello') }
    Timecop.freeze(Time.utc(2023, 1, 2, 21, 22, 23)) { logger.trace('hello') }
    
    # Expect duplicates due to two loggers being active
    expected = [
      "\e[2m[03:04:05]\e[0m DEBUG: hello\n",
      "\e[2m[03:04:05]\e[0m DEBUG: hello\n",
      "\e[2m[06:07:08]\e[0m  INFO: hello\n",
      "\e[2m[06:07:08]\e[0m  INFO: hello\n",
      "\e[2m[09:10:11]\e[0m  WARN: hello\n",
      "\e[2m[09:10:11]\e[0m  WARN: hello\n",
      "\e[2m[12:13:14]\e[0m ERROR: hello\n",
      "\e[2m[12:13:14]\e[0m ERROR: hello\n",
      "\e[2m[15:16:17]\e[0m FATAL: hello\n",
      "\e[2m[15:16:17]\e[0m FATAL: hello\n",
      "\e[2m[18:19:20]\e[0m   ANY: hello\n",
      "\e[2m[18:19:20]\e[0m   ANY: hello\n"
    ]
    
    io.rewind
    assert_equal(expected, io.readlines)
  end

  def test_dual_logger_defaults
    file_io = StringIO.new
    stdout_io = StringIO.new

    logger = Maze::Loggers::Logger.instance
    logger.stdout_logger.reopen(stdout_io)
    logger.file_logger.reopen(file_io)

    stdout_io.rewind
    assert_empty(stdout_io.read)

    file_io.rewind
    assert_empty(file_io.read)

    Timecop.freeze(Time.utc(2023, 1, 2, 3, 4, 5)) { logger.trace('hello') }
    Timecop.freeze(Time.utc(2023, 1, 2, 6, 7, 8)) { logger.debug('hello') }
    Timecop.freeze(Time.utc(2023, 1, 2, 9, 10, 11)) { logger.info('hello') }
    Timecop.freeze(Time.utc(2023, 1, 2, 12, 13, 14)) { logger.warn('hello') }

    file_expected = [
      "\e[2m[03:04:05]\e[0m TRACE: hello\n",
      "\e[2m[06:07:08]\e[0m DEBUG: hello\n",
      "\e[2m[09:10:11]\e[0m  INFO: hello\n",
      "\e[2m[12:13:14]\e[0m  WARN: hello\n"
    ]

    file_io.rewind
    assert_equal(file_expected, file_io.readlines)

    stdout_expected = [
      "\e[2m[09:10:11]\e[0m  INFO: hello\n",
      "\e[2m[12:13:14]\e[0m  WARN: hello\n"
    ]

    stdout_io.rewind
    assert_equal(stdout_expected, stdout_io.readlines)
  end
  
  def test_the_datetime_format_can_be_changed
    io = StringIO.new
    
    logger = Maze::Loggers::Logger.instance
    logger.level = Logger::DEBUG
    logger.reopen(io)

    io.rewind
    assert_empty(io.read)

    Timecop.freeze(Time.utc(2023, 1, 2, 3, 4, 5)) { logger.debug('hello') }
    Timecop.freeze(Time.utc(2023, 1, 2, 6, 7, 8)) { logger.info('hello') }
    Timecop.freeze(Time.utc(2023, 1, 2, 9, 10, 11)) { logger.warn('hello') }

    logger.datetime_format = '%Y-%m-%d %H:%M:%S'

    Timecop.freeze(Time.utc(2023, 1, 2, 12, 13, 14)) { logger.error('hello') }
    Timecop.freeze(Time.utc(2023, 3, 4, 15, 16, 17)) { logger.fatal('hello') }
    Timecop.freeze(Time.utc(2023, 5, 6, 18, 19, 20)) { logger.unknown('hello') }

    # Expect duplicates due to two loggers being active
    expected = [
      "\e[2m[03:04:05]\e[0m DEBUG: hello\n",
      "\e[2m[03:04:05]\e[0m DEBUG: hello\n",
      "\e[2m[06:07:08]\e[0m  INFO: hello\n",
      "\e[2m[06:07:08]\e[0m  INFO: hello\n",
      "\e[2m[09:10:11]\e[0m  WARN: hello\n",
      "\e[2m[09:10:11]\e[0m  WARN: hello\n",
      "\e[2m[2023-01-02 12:13:14]\e[0m ERROR: hello\n",
      "\e[2m[2023-01-02 12:13:14]\e[0m ERROR: hello\n",
      "\e[2m[2023-03-04 15:16:17]\e[0m FATAL: hello\n",
      "\e[2m[2023-03-04 15:16:17]\e[0m FATAL: hello\n",
      "\e[2m[2023-05-06 18:19:20]\e[0m   ANY: hello\n",
      "\e[2m[2023-05-06 18:19:20]\e[0m   ANY: hello\n"
    ]

    io.rewind
    assert_equal(expected, io.readlines)
  end

  def test_the_formatter_can_be_changed
    io = StringIO.new

    logger = Maze::Loggers::Logger.instance
    logger.level = Logger::DEBUG
    logger.reopen(io)

    io.rewind
    assert_empty(io.read)

    Timecop.freeze(Time.utc(2023, 1, 2, 3, 4, 5)) { logger.debug('hello') }
    Timecop.freeze(Time.utc(2023, 1, 2, 6, 7, 8)) { logger.info('hello') }
    Timecop.freeze(Time.utc(2023, 1, 2, 9, 10, 11)) { logger.warn('hello') }

    logger.formatter = proc do |*args|
      args.map(&:inspect).join(" ~ ") + "\n"
    end

    Timecop.freeze(Time.utc(2023, 1, 2, 12, 13, 14)) { logger.error('hello') }
    Timecop.freeze(Time.utc(2023, 3, 4, 15, 16, 17)) { logger.fatal('hello') }
    Timecop.freeze(Time.utc(2023, 5, 6, 18, 19, 20)) { logger.unknown('hello') }

    expected = [
      "\e[2m[03:04:05]\e[0m DEBUG: hello\n",
      "\e[2m[03:04:05]\e[0m DEBUG: hello\n",
      "\e[2m[06:07:08]\e[0m  INFO: hello\n",
      "\e[2m[06:07:08]\e[0m  INFO: hello\n",
      "\e[2m[09:10:11]\e[0m  WARN: hello\n",
      "\e[2m[09:10:11]\e[0m  WARN: hello\n",
      "\"ERROR\" ~ 2023-01-02 12:13:14 UTC ~ nil ~ \"hello\"\n",
      "\"ERROR\" ~ 2023-01-02 12:13:14 UTC ~ nil ~ \"hello\"\n",
      "\"FATAL\" ~ 2023-03-04 15:16:17 UTC ~ nil ~ \"hello\"\n",
      "\"FATAL\" ~ 2023-03-04 15:16:17 UTC ~ nil ~ \"hello\"\n",
      "\"ANY\" ~ 2023-05-06 18:19:20 UTC ~ nil ~ \"hello\"\n",
      "\"ANY\" ~ 2023-05-06 18:19:20 UTC ~ nil ~ \"hello\"\n"
    ]

    io.rewind
    assert_equal(expected, io.readlines)
  end

  private

  def reset_logger!
    @initial_formatter ||= Maze::Loggers::Logger.instance.formatter
    @initial_datetime_format ||= Maze::Loggers::Logger.instance.datetime_format

    Maze::Loggers::Logger.instance.formatter = @initial_formatter
    Maze::Loggers::Logger.instance.datetime_format = @initial_datetime_format
  end
end
