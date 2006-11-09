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

class OrphanAttachmentTest < Test::Unit::TestCase
  include BaseAttachmentTests
  attachment_model OrphanAttachment
  
  def test_should_create_image_from_uploaded_file
    assert_created do
      attachment = upload_file :filename => '/files/rails.png'
      assert_valid attachment
      assert !attachment.db_file.new_record? if attachment.respond_to?(:db_file)
      assert  attachment.image?
      assert !attachment.size.zero?
    end
  end
  
  def test_should_create_file_from_uploaded_file
    assert_created do
      attachment = upload_file :filename => '/files/foo.txt'
      assert_valid attachment
      assert !attachment.db_file.new_record? if attachment.respond_to?(:db_file)
      assert  attachment.image?
      assert !attachment.size.zero?
    end
  end
  
  def test_should_create_image_from_uploaded_file_with_custom_content_type
    assert_created do
      attachment = upload_file :content_type => 'foo/bar', :filename => '/files/rails.png'
      assert_valid attachment
      assert !attachment.image?
      assert !attachment.db_file.new_record? if attachment.respond_to?(:db_file)
      assert !attachment.size.zero?
      #assert_equal 1784, attachment.size
    end
  end
  
  def test_should_create_thumbnail
    attachment = upload_file :filename => '/files/rails.png'
    
    assert_raise Technoweenie::ActsAsAttachment::ThumbnailError do
      attachment.create_or_update_thumbnail('thumb', 50, 50)
    end
  end
  
  def test_should_create_thumbnail_with_geometry_string
   attachment = upload_file :filename => '/files/rails.png'
    
    assert_raise Technoweenie::ActsAsAttachment::ThumbnailError do
      attachment.create_or_update_thumbnail('thumb', 'x50')
    end
  end
end

class MinimalAttachmentTest < OrphanAttachmentTest
  attachment_model MinimalAttachment
end