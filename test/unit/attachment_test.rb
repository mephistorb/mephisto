require File.dirname(__FILE__) + '/../test_helper'

class AttachmentTest < Test::Unit::TestCase
  fixtures :attachments, :sites

  def test_should_count_correct_assets
    assert_equal 14, Attachment.count
    assert_equal 12, sites(:first).attachments.count
    assert_equal 1, sites(:hostess).attachments.count
  end
end
