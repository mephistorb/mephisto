require File.dirname(__FILE__) + '/../test_helper'

class AttachmentTest < Test::Unit::TestCase
  fixtures :attachments, :db_files

  def test_should_count_correct_assets
    assert_equal 14, Attachment.count
  end

  def test_should_sanitize_path
    a = Attachment.create :content_type => 'text/plain', :filename => 'foo.txt', :path => '//foo/bar/baz////', :attachment_data => 'foo'
    assert a.id
    assert_equal 'foo/bar/baz', a.path
  end

  def test_should_find_by_full_path
    assert_equal attachments(:css),     Attachment.find_by_full_path('stylesheets/style.css')
    assert_equal attachments(:js),      Attachment.find_by_full_path('javascripts/behavior.js')
    assert_equal attachments(:quentin), Attachment.find_by_full_path('images/users/quentin.png')
    assert_equal attachments(:site),    Attachment.find_by_full_path('images/site/foobar.png')
  end
end
