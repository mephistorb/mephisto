require File.join(File.dirname(__FILE__), 'abstract_unit')

class ContentTypeTest < Test::Unit::TestCase
  def test_should_reject_invalid_content_type(klass = PdfAttachment)
    attachment_model klass
    assert_not_created do
      attachment = upload_file :filename => '/files/rails.png'
      assert attachment.new_record?
      assert attachment.errors.on(:content_type)
    end
  end
  
  test_against_subclass :test_should_reject_invalid_content_type, PdfAttachment
  
  def test_should_allow_single_content_type(klass = PdfAttachment)
    attachment_model klass
    assert_created do
      attachment = upload_file :content_type => 'pdf', :filename => '/files/rails.png'
      assert_valid attachment
    end
  end
  
  test_against_subclass :test_should_allow_single_content_type, PdfAttachment

  def test_should_allow_single_image_content_type(klass = ImageAttachment)
    attachment_model klass
    assert_created do
      attachment = upload_file :content_type => 'image/png', :filename => '/files/rails.png'
      assert_valid attachment
    end
  end
  
  test_against_subclass :test_should_allow_single_image_content_type, ImageAttachment
  
  def test_should_allow_multiple_content_types(klass = DocAttachment)
    attachment_model klass
    assert_created 3 do
      attachment = upload_file :content_type => 'pdf', :filename => '/files/rails.png'
      assert_valid attachment
      attachment = upload_file :content_type => 'doc', :filename => '/files/rails.png'
      assert_valid attachment
      attachment = upload_file :content_type => 'txt', :filename => '/files/rails.png'
      assert_valid attachment
    end
  end
  
  test_against_subclass :test_should_allow_multiple_content_types, DocAttachment
  
  def test_should_allow_multiple_content_types_with_images(klass = ImageOrPdfAttachment)
    attachment_model klass
    assert_created 2 do
      attachment = upload_file :content_type => 'pdf', :filename => '/files/rails.png'
      assert_valid attachment
      attachment = upload_file :content_type => 'image/png', :filename => '/files/rails.png'
      assert_valid attachment
    end
  end
  
  test_against_subclass :test_should_allow_multiple_content_types_with_images, ImageOrPdfAttachment

  def test_should_verify_image_content_types
    ['image/jpeg', 'image/pjpeg', 'image/gif', 'image/png', 'image/x-png'].each do |content_type|
      assert Attachment.image?(content_type)
    end
    ['text/plain', 'application/x-xls', 'application/xml'].each do |content_type|
      assert !Attachment.image?(content_type)
    end
  end
end