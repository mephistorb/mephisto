require File.join(File.dirname(__FILE__), 'abstract_unit')

class AttachmentTest < Test::Unit::TestCase
  def setup
    FileUtils.rm_rf File.join(File.dirname(__FILE__), 'files')
  end

  def test_should_create_image_from_uploaded_file
    assert_created Attachment do
      attachment = upload_file
      assert !attachment.new_record?, attachment.errors.full_messages.join("\n")
      assert !attachment.db_file.new_record? if attachment.respond_to?(:db_file)
      assert  attachment.image?
      assert_equal 1784, attachment.size
      assert_equal 50,   attachment.width
      assert_equal 64,   attachment.height
    end
  end

  def test_should_create_file_from_uploaded_file
    assert_created Attachment do
      attachment = upload_file :filename => '/files/foo.txt'
      assert !attachment.new_record?, attachment.errors.full_messages.join("\n")
      assert !attachment.db_file.new_record? if attachment.respond_to?(:db_file)
      assert  attachment.image?
      assert_equal 3, attachment.size
      assert_nil      attachment.width
      assert_nil      attachment.height
    end
  end

  def test_should_create_image_from_uploaded_file_with_custom_content_type
    assert_created Attachment do
      attachment = upload_file :content_type => 'foo/bar'
      assert !attachment.new_record?, attachment.errors.full_messages.join("\n")
      assert !attachment.image?
      assert !attachment.db_file.new_record? if attachment.respond_to?(:db_file)
      assert_equal 1784, attachment.size
      assert_equal 50,   attachment.width
      assert_equal 64,   attachment.height
      assert_equal [],   attachment.thumbnails
    end
  end

  def test_should_create_thumbnail
    attachment = nil
    assert_created Attachment do
      attachment = upload_file
      assert !attachment.new_record?, attachment.errors.full_messages.join("\n")
    end
    assert_equal 50, attachment.width
    assert_equal 64, attachment.height
    
    assert_created Attachment do
      basename, ext = attachment.filename.split '.'
      thumbnail = attachment.create_thumbnail 'thumb', 50, 50
      assert !thumbnail.new_record?, thumbnail.errors.full_messages.join("\n")
      assert_in_delta 4673, thumbnail.size, 2
      assert_equal 50,   thumbnail.width
      assert_equal 50,   thumbnail.height
      assert_equal [thumbnail], attachment.thumbnails
      assert_equal attachment,  thumbnail.parent
      assert_equal "#{basename}_thumb.#{ext}", thumbnail.filename
    end
  end

  def test_should_create_thumbnail_with_geometry_string
    attachment = nil
    assert_created Attachment do
      attachment = upload_file
      assert !attachment.new_record?, attachment.errors.full_messages.join("\n")
    end
    assert_equal 50, attachment.width
    assert_equal 64, attachment.height
    
    assert_created Attachment do
      basename, ext = attachment.filename.split '.'
      thumbnail = attachment.create_thumbnail 'thumb', 'x50'
      assert !thumbnail.new_record?, thumbnail.errors.full_messages.join("\n")
      assert_equal 3915, thumbnail.size
      assert_equal 39,   thumbnail.width
      assert_equal 50,   thumbnail.height
      assert_equal [thumbnail], attachment.thumbnails
      assert_equal attachment,  thumbnail.parent
      assert_equal "#{basename}_thumb.#{ext}", thumbnail.filename
    end
  end

  def test_should_resize_image(klass = ImageAttachment)
    assert_equal [50, 50], klass.attachment_options[:resize_to]
    attachment = upload_file :class => klass
    assert !attachment.new_record?, attachment.errors.full_messages.join("\n")
    assert !attachment.db_file.new_record? if attachment.respond_to?(:db_file)
    assert  attachment.image?
    assert_in_delta 4673, attachment.size, 2
    assert_equal 50,   attachment.width
    assert_equal 50,   attachment.height
  end

  def test_should_resize_image_with_geometry(klass = ImageOrPdfAttachment)
    assert_equal 'x50', klass.attachment_options[:resize_to]
    attachment = upload_file :class => klass
    assert !attachment.new_record?, attachment.errors.full_messages.join("\n")
    assert !attachment.db_file.new_record? if attachment.respond_to?(:db_file)
    assert  attachment.image?
    assert_equal 3915, attachment.size
    assert_equal 39,   attachment.width
    assert_equal 50,   attachment.height
  end

  def test_should_automatically_create_thumbnails(klass = ImageWithThumbsAttachment)
    assert_created klass, 3 do
      attachment = upload_file :class => klass
      assert !attachment.new_record?, attachment.errors.full_messages.join("\n")
      assert_equal 1784, attachment.size
      assert_equal 50,   attachment.width
      assert_equal 64,   attachment.height
      assert_equal 2,    attachment.thumbnails.length
      
      thumb = attachment.thumbnails.detect { |t| t.filename =~ /_thumb/ }
      assert !thumb.new_record?, thumb.errors.full_messages.join("\n")
      assert_in_delta 4673, thumb.size, 2
      assert_equal 50,   thumb.width
      assert_equal 50,   thumb.height
      
      geo   = attachment.thumbnails.detect { |t| t.filename =~ /_geometry/ }
      assert !geo.new_record?, geo.errors.full_messages.join("\n")
      assert_equal 3915, geo.size
      assert_equal 39,   geo.width
      assert_equal 50,   geo.height
    end
  end
  
  #TODO: This is just a copy of the test above, need to find a way of making
  # assert_created Attachment, only check for a DbFile record if the attachment
  # is stored in the database
  def test_should_automatically_create_thumbnails_for_file_attachment(klass = ImageWithThumbsFileAttachment)
    assert_created klass, 3 do
      attachment = upload_file :class => klass
      assert !attachment.new_record?, attachment.errors.full_messages.join("\n")
      assert_equal 1784, attachment.size
      
      assert_equal 50,   attachment.width
      assert_equal 64,   attachment.height
      assert_equal 2,    attachment.thumbnails.length
      
      thumb = attachment.thumbnails.detect { |t| t.filename =~ /_thumb/ }
      assert !thumb.new_record?, thumb.errors.full_messages.join("\n")
      assert_in_delta 4673, thumb.size, 2
      assert_equal 50,   thumb.width
      assert_equal 50,   thumb.height
      
      geo   = attachment.thumbnails.detect { |t| t.filename =~ /_geometry/ }
      assert !geo.new_record?, geo.errors.full_messages.join("\n")
      assert_equal 3915, geo.size
      assert_equal 39,   geo.width
      assert_equal 50,   geo.height
    end
  end
  
  def test_filesystem_size_for_file_attachment(klass = FileAttachment)
    assert_created klass, 1 do
      attachment = upload_file :class => klass
      assert_equal 1784, attachment.size
      assert_equal attachment.size, File.open(attachment.full_filename).stat.size
    end
  end
  
  def test_should_not_overwrite_file_attachment(klass = FileAttachment)
    assert_created klass, 2 do
      real = upload_file :class => klass, :filename => '/files/rails.png'
      assert !real.new_record?, real.errors.full_messages.join("\n")
      assert_equal 1784,  real.size
      
      fake = upload_file :class => klass, :filename => '/files/fake/rails.png'
      assert !fake.new_record?, fake.errors.full_messages.join("\n")
      assert_equal 4473,  fake.size
      
      real.reload && fake.reload
      assert_not_equal real.attachment_data, fake.attachment_data
      assert_not_equal File.open(real.full_filename).stat.size, File.open(fake.full_filename).stat.size
    end
  end

  def test_should_reject_big_file
    should_reject_by_size_with BigAttachment
  end

  def test_should_reject_small_file
    should_reject_by_size_with SmallAttachment
  end

  def test_should_reject_invalid_content_type(klass = PdfAttachment)
    assert_no_attachment_created do
      attachment = upload_file :class => klass
      assert attachment.new_record?
      assert attachment.errors.on(:content_type)
    end
  end

  def test_should_allow_single_content_type(klass = PdfAttachment)
    assert_created Attachment do
      attachment = upload_file :class => klass, :content_type => 'pdf'
      assert !attachment.new_record?, attachment.errors.full_messages.join("\n")
    end
  end

  def test_should_allow_single_image_content_type(klass = ImageAttachment)
    assert_created klass do
      attachment = upload_file :class => klass, :content_type => 'image/png'
      assert !attachment.new_record?, attachment.errors.full_messages.join("\n")
    end
  end

  def test_should_allow_multiple_content_types(klass = DocAttachment)
    assert_created klass, 3 do
      attachment = upload_file :class => klass, :content_type => 'pdf'
      assert !attachment.new_record?, attachment.errors.full_messages.join("\n")
      attachment = upload_file :class => klass, :content_type => 'doc'
      assert !attachment.new_record?, attachment.errors.full_messages.join("\n")
      attachment = upload_file :class => klass, :content_type => 'txt'
      assert !attachment.new_record?, attachment.errors.full_messages.join("\n")
    end
  end

  def test_should_allow_multiple_content_types_with_images(klass = ImageOrPdfAttachment)
    assert_created klass, 2 do
      attachment = upload_file :class => klass, :content_type => 'pdf'
      assert !attachment.new_record?, attachment.errors.full_messages.join("\n")
      attachment = upload_file :class => klass, :content_type => 'image/png'
      assert !attachment.new_record?, attachment.errors.full_messages.join("\n")
    end
  end
  
  def test_should_require_size
    assert_no_attachment_created do
      att = Attachment.new :attachment_data => 'foo', :content_type => 'text/plain', :filename => 'foo.txt'
      att.size = nil
      assert !att.save
      assert att.errors.on(:size)
    end
  end

  def test_should_require_filename
    assert_no_attachment_created do
      att = Attachment.new :attachment_data => 'foo', :content_type => 'text/plain'
      assert !att.save
      assert att.errors.on(:filename)
    end
  end

  def test_should_require_content_type
    assert_no_attachment_created do
      att = Attachment.new :attachment_data => 'foo', :filename => 'foo.txt'
      assert !att.save
      assert att.errors.on(:content_type)
    end
  end
  
  def test_reassign_attribute_data(klass = Attachment)
    assert_created klass, 1 do
      attachment = upload_file :class => klass
      assert !attachment.new_record?, attachment.errors.full_messages.join("\n")
      assert attachment.attachment_data.size > 0, "no data was set"
      
      attachment.attachment_data = 'wtf'
      attachment.save
      
      assert_equal 'wtf', klass.find(attachment.id).attachment_data
    end
  end
  
  def test_no_reassign_attribute_data_on_nil(klass = Attachment)
    assert_created klass, 1 do
      attachment = upload_file :class => klass
      assert !attachment.new_record?, attachment.errors.full_messages.join("\n")
      assert attachment.attachment_data.size > 0, "no data was set"
      
      original = attachment.attachment_data.clone.freeze
      attachment.attachment_data = nil
      attachment.save
      
      assert_equal original, klass.find(attachment.id).attachment_data
    end
  end
  
  def test_should_store_file_attachment_in_filesystem(klass = FileAttachment)
    assert_created klass do
      attachment = upload_file :class => klass
      assert !attachment.new_record?, attachment.errors.full_messages.join("\n")
      
      saved_file_path = File.join(RAILS_ROOT, attachment.attachment_options[:file_system_path], attachment.id.to_s, attachment.filename)
      assert File.exists?(saved_file_path), "#{saved_file_path} does not exist"    
    end
  end
  
  def test_should_delete_file_when_in_file_system_when_attachment_record_destroyed(klass = FileAttachment)
    attachment = upload_file :class => klass
    saved_file_path = attachment.full_filename
    assert File.exists?(saved_file_path), "#{saved_file_path} never existed to delete on destroy"
    attachment.destroy
    assert !File.exists?(saved_file_path), "#{saved_file_path} still exists"    
  end
  
  # test that simple subclasses still work
  {
    :test_should_resize_image                             => ImageAttachment,
    :test_should_resize_image_with_geometry               => ImageOrPdfAttachment,
    :test_should_automatically_create_thumbnails          => ImageWithThumbsAttachment,
    :test_should_reject_invalid_content_type              => PdfAttachment,
    :test_should_allow_single_content_type                => PdfAttachment,
    :test_should_allow_single_image_content_type          => ImageAttachment,
    :test_should_allow_multiple_content_types             => DocAttachment,
    :test_should_allow_multiple_content_types_with_images => ImageOrPdfAttachment,
    :test_should_resize_image                             => ImageFileAttachment,
    :test_reassign_attribute_data                         => FileAttachment,
    :test_no_reassign_attribute_data_on_nil               => FileAttachment,
 }.each do |test_method, klass|
    define_method("#{test_method}_on_subclass") { send test_method, Class.new(klass) }
  end

  protected
    def upload_file(options = {})
      att = (options[:class] || Attachment).create :uploaded_data => fixture_file_upload(options[:filename] || '/files/rails.png', options[:content_type] || 'image/png')
      att.reload unless att.new_record?
      att
    end
    
    def assert_created(klass = Attachment, num = 1)
      assert_difference klass, :count, num do
        if klass.included_modules.include? DbFile
          assert_difference DbFile, :count, num do
            yield
          end
        else
          yield
        end
      end
    end
    
    def assert_no_attachment_created
      assert_created Attachment, 0 do
        yield
      end
    end
    
    def should_reject_by_size_with(klass)
      assert_no_attachment_created do
        attachment = upload_file :class => klass
        assert attachment.new_record?
        assert attachment.errors.on(:size)
        assert_nil attachment.db_file if attachment.respond_to?(:db_file)
      end
    end
end
