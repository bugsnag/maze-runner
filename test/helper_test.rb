require 'test_helper'
require_relative '../lib/maze/helper'

class HelperTest < Test::Unit::TestCase

  def test_valid_sha_digest_header
    request = {
      request: {
        'Bugsnag-Integrity' => 'sha1 3cac245198d9b6e6a91b7d46b5117311f20d9eba'
      },
      digests: {
        sha1: '3cac245198d9b6e6a91b7d46b5117311f20d9eba'
      }
    }
    assert_true(Maze::Helper.valid_bugsnag_integrity_header(request))
  end

  def test_valid_simple_digest_header
    request = {
      request: {
        'Bugsnag-Integrity' => 'simple 12'
      },
      digests: {
        simple: 12
      }
    }
    assert_true(Maze::Helper.valid_bugsnag_integrity_header(request))
  end

  def test_invalid_sha_digest_header
    request = {
      request: {
        'Bugsnag-Integrity' => 'sha1 3cac245198d9b6e6a91b7d46b5117311f20d9eba'
      },
      digests: {
        sha1: '111115198d9b6e6a91b7d46b5117311f20d9eba'
      }
    }
    assert_false(Maze::Helper.valid_bugsnag_integrity_header(request))
  end

  def test_invalid_simple_digest_header
    request = {
      request: {
        'Bugsnag-Integrity' => 'simple 12'
      },
      digests: {
        simple: 13
      }
    }
    assert_false(Maze::Helper.valid_bugsnag_integrity_header(request))
  end
end
