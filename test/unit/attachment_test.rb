require File.dirname(__FILE__) + '/../test_helper'

class AttachmentTest < Test::Unit::TestCase
  fixtures :sites

  def setup
    prepare_theme_fixtures
  end

  def test_should_count_correct_assets
    assert_equal 15, sites(:first).attachments.size
    assert_equal 5,  sites(:hostess).attachments.size
  end
end
