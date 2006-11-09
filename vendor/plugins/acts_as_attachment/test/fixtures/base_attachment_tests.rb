module BaseAttachmentTests
  def test_should_create_image_from_uploaded_file
    assert_created do
      attachment = upload_file :filename => '/files/rails.png'
      assert_valid attachment
      assert !attachment.db_file.new_record? if attachment.respond_to?(:db_file)
      assert  attachment.image?
      assert !attachment.size.zero?
      #assert_equal 1784, attachment.size
      assert_equal 50,   attachment.width
      assert_equal 64,   attachment.height
      assert_equal '50x64', attachment.image_size
    end
  end
  
  def test_should_create_file_from_uploaded_file
    assert_created do
      attachment = upload_file :filename => '/files/foo.txt'
      assert_valid attachment
      assert !attachment.db_file.new_record? if attachment.respond_to?(:db_file)
      assert  attachment.image?
      assert !attachment.size.zero?
      #assert_equal 3, attachment.size
      assert_nil      attachment.width
      assert_nil      attachment.height
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
      assert_nil attachment.width
      assert_nil attachment.height
      assert_equal [], attachment.thumbnails
    end
  end
  
  def test_should_create_thumbnail
    attachment = upload_file :filename => '/files/rails.png'
    
    assert_created do
      basename, ext = attachment.filename.split '.'
      thumbnail = attachment.create_or_update_thumbnail('thumb', 50, 50)
      assert_valid thumbnail
      assert !thumbnail.size.zero?
      #assert_in_delta 4673, thumbnail.size, 2
      assert_equal 50,   thumbnail.width
      assert_equal 50,   thumbnail.height
      assert_equal [thumbnail], attachment.thumbnails
      assert_equal attachment.id,  thumbnail.parent_id if thumbnail.respond_to?(:parent_id)
      assert_equal "#{basename}_thumb.#{ext}", thumbnail.filename
    end
  end
  
  def test_should_create_thumbnail_with_geometry_string
   attachment = upload_file :filename => '/files/rails.png'
    
    assert_created do
      basename, ext = attachment.filename.split '.'
      thumbnail = attachment.create_or_update_thumbnail('thumb', 'x50')
      assert_valid thumbnail
      assert !thumbnail.size.zero?
      #assert_equal 3915, thumbnail.size
      assert_equal 39,   thumbnail.width
      assert_equal 50,   thumbnail.height
      assert_equal [thumbnail], attachment.thumbnails
      assert_equal attachment.id,  thumbnail.parent_id if thumbnail.respond_to?(:parent_id)
      assert_equal "#{basename}_thumb.#{ext}", thumbnail.filename
    end
  end
  
  def test_reassign_attribute_data
    assert_created 1 do
      attachment = upload_file :filename => '/files/rails.png'
      assert_valid attachment
      assert attachment.attachment_data.size > 0, "no data was set"
      
      attachment.attachment_data = 'wtf'
      attachment.save
      
      assert_equal 'wtf', attachment_model.find(attachment.id).attachment_data
    end
  end
  
  def test_no_reassign_attribute_data_on_nil
    assert_created 1 do
      attachment = upload_file :filename => '/files/rails.png'
      assert_valid attachment
      assert attachment.attachment_data.size > 0, "no data was set"
      
      attachment.attachment_data = nil
      assert !attachment.instance_variable_get(:@save_attachment)
    end
  end
  
  def test_should_overwrite_old_contents_when_updating
    attachment   = upload_file :filename => '/files/rails.png'
    assert_not_created do # no new db_file records
      attachment.filename        = 'rails2.png'
      attachment.attachment_data = IO.read(File.join(File.dirname(__FILE__), 'files/rails.png'))
      attachment.save
    end
  end
end