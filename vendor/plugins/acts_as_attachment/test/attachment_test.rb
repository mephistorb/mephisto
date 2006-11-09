require File.join(File.dirname(__FILE__), 'abstract_unit')

class DbAttachmentTest < Test::Unit::TestCase
  include BaseAttachmentTests
  attachment_model Attachment

  def test_should_call_after_attachment_saved(klass = Attachment)
    attachment_model Attachment
    attachment_model.saves = 0
    assert_created do
      upload_file :filename => '/files/rails.png'
    end
    assert_equal 1, attachment_model.saves
  end
  
  test_against_subclass :test_should_call_after_attachment_saved, Attachment
end

#class OrphanAttachmentTest < Test::Unit::TestCase
#  include BaseAttachmentTests
#  attachment_model OrphanAttachment
#end
#
#class MinimalAttachmentTest < Test::Unit::TestCase
#  include BaseAttachmentTests
#  attachment_model MinimalAttachment
#end