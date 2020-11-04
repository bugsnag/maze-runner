require 'test_helper'
require_relative '../lib/features/support/header'

class HeaderTest < Test::Unit::TestCase

  def test_valid_sha_digest_header
    request = {:request => { "Bugsnag-Integrity" => "sha1 3cac245198d9b6e6a91b7d46b5117311f20d9eba"}, :body => {"apiKey" => "your-api-key"}}
    assert_true(valid_sha_digest_header(request))
  end

  def test_invalid_sha_digest_header
    request = {:request => { "Bugsnag-Integrity" => "sha1 5522240098dcc6e6a91ab936b5192911f2aa9000"}, :body => {"apiKey" => "your-api-key"}}
    assert_raise do
      assert_false(valid_sha_digest_header(request))
    end
  end

  def test_valid_simple_digest_header
    request = {:request => { "Bugsnag-Integrity" => "simple 25"}, :body => {"apiKey" => "your-api-key"}}
    assert_true(valid_simple_digest_header(request))
  end

  def test_invalid_simple_digest_header
    request = {:request => { "Bugsnag-Integrity" => "simple 509"}, :body => {"apiKey" => "your-api-key"}}
    assert_raise do
      assert_true(valid_simple_digest_header(request))
    end
  end

end
