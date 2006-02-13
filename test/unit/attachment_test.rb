require File.dirname(__FILE__) + '/../test_helper'

class AttachmentTest < Test::Unit::TestCase
  fixtures :attachments, :db_files

  def test_should_count_correct_assets
    assert_equal 13, Attachment.count
  end

  def test_should_sanitize_path
    a = Attachment.create :content_type => 'text/plain', :filename => 'foo.txt', :path => '//foo/bar/baz////', :attachment_data => 'foo'
    assert a.id
    assert_equal 'foo/bar/baz', a.path
  end
end
