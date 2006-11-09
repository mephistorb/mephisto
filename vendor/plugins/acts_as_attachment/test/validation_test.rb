require File.join(File.dirname(__FILE__), 'abstract_unit')

class ValidationTest < Test::Unit::TestCase
  attachment_model Attachment

  def test_should_require_size
    assert_not_created do
      att = Attachment.new :attachment_data => 'foo', :content_type => 'text/plain', :filename => 'foo.txt'
      att.size = nil
      assert !att.save
      assert att.errors.on(:size)
    end
  end
  
  def test_should_require_filename
    assert_not_created do
      att = Attachment.new :attachment_data => 'foo', :content_type => 'text/plain'
      assert !att.save
      assert att.errors.on(:filename)
    end
  end
  
  def test_should_require_content_type
    assert_not_created do
      att = Attachment.new :attachment_data => 'foo', :filename => 'foo.txt'
      assert !att.save
      assert att.errors.on(:content_type)
    end
  end

  def test_should_reject_big_file
    should_reject_by_size_with BigAttachment
  end
  
  def test_should_reject_small_file
    should_reject_by_size_with SmallAttachment
  end
end