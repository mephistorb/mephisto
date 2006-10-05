require File.join(File.dirname(__FILE__), 'abstract_unit')

# All sizes are commented out because they vary wildly among platforms
class AttachmentTest < Test::Unit::TestCase
  def setup
    FileUtils.rm_rf File.join(File.dirname(__FILE__), 'files')
  end

  def test_should_create_image_from_uploaded_file
    assert_created Attachment do
      attachment = upload_file :filename => '/files/rails.png'
      assert !attachment.new_record?, attachment.errors.full_messages.join("\n")
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
    assert_created Attachment do
      attachment = upload_file :filename => '/files/foo.txt'
      assert !attachment.new_record?, attachment.errors.full_messages.join("\n")
      assert !attachment.db_file.new_record? if attachment.respond_to?(:db_file)
      assert  attachment.image?
      assert !attachment.size.zero?
      #assert_equal 3, attachment.size
      assert_nil      attachment.width
      assert_nil      attachment.height
    end
  end

  def test_should_create_image_from_uploaded_file_with_custom_content_type
    assert_created Attachment do
      attachment = upload_file :content_type => 'foo/bar', :filename => '/files/rails.png'
      assert !attachment.new_record?, attachment.errors.full_messages.join("\n")
      assert !attachment.image?
      assert !attachment.db_file.new_record? if attachment.respond_to?(:db_file)
      assert !attachment.size.zero?
      #assert_equal 1784, attachment.size
      assert_nil attachment.width
      assert_nil attachment.height
      assert_equal [],   attachment.thumbnails
    end
  end

  def test_should_create_thumbnail
    attachment = nil
    assert_created Attachment do
      attachment = upload_file :filename => '/files/rails.png'
      assert !attachment.new_record?, attachment.errors.full_messages.join("\n")
    end
    assert_equal 50, attachment.width
    assert_equal 64, attachment.height
    
    assert_created Attachment do
      basename, ext = attachment.filename.split '.'
      thumbnail = attachment.create_or_update_thumbnail('thumb', 50, 50)
      assert !thumbnail.new_record?, thumbnail.errors.full_messages.join("\n")
      assert !thumbnail.size.zero?
      #assert_in_delta 4673, thumbnail.size, 2
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
      attachment = upload_file :filename => '/files/rails.png'
      assert !attachment.new_record?, attachment.errors.full_messages.join("\n")
    end
    assert_equal 50, attachment.width
    assert_equal 64, attachment.height
    
    assert_created Attachment do
      basename, ext = attachment.filename.split '.'
      thumbnail = attachment.create_or_update_thumbnail('thumb', 'x50')
      assert !thumbnail.new_record?, thumbnail.errors.full_messages.join("\n")
      assert !thumbnail.size.zero?
      #assert_equal 3915, thumbnail.size
      assert_equal 39,   thumbnail.width
      assert_equal 50,   thumbnail.height
      assert_equal [thumbnail], attachment.thumbnails
      assert_equal attachment,  thumbnail.parent
      assert_equal "#{basename}_thumb.#{ext}", thumbnail.filename
    end
  end

  def test_should_resize_image(klass = ImageAttachment)
    assert_equal [50, 50], klass.attachment_options[:resize_to]
    attachment = upload_file :class => klass, :filename => '/files/rails.png'
    assert !attachment.new_record?, attachment.errors.full_messages.join("\n")
    assert !attachment.db_file.new_record? if attachment.respond_to?(:db_file)
    assert  attachment.image?
    assert !attachment.size.zero?
    #assert_in_delta 4673, attachment.size, 2
    assert_equal 50,   attachment.width
    assert_equal 50,   attachment.height
  end

  def test_should_resize_image_with_geometry(klass = ImageOrPdfAttachment)
    assert_equal 'x50', klass.attachment_options[:resize_to]
    attachment = upload_file :class => klass, :filename => '/files/rails.png'
    assert !attachment.new_record?, attachment.errors.full_messages.join("\n")
    assert !attachment.db_file.new_record? if attachment.respond_to?(:db_file)
    assert  attachment.image?
    assert !attachment.size.zero?
    #assert_equal 3915, attachment.size
    assert_equal 39,   attachment.width
    assert_equal 50,   attachment.height
  end

  def test_should_automatically_create_thumbnails(klass = ImageWithThumbsAttachment)
    assert_created klass, 3 do
      attachment = upload_file :class => klass, :filename => '/files/rails.png'
      assert !attachment.new_record?, attachment.errors.full_messages.join("\n")
      assert !attachment.size.zero?
      #assert_equal 1784, attachment.size
      assert_equal 55,   attachment.width
      assert_equal 55,   attachment.height
      assert_equal 2,    attachment.thumbnails.length
      assert_equal 1.0,  attachment.aspect_ratio
      
      thumb = attachment.thumbnails.detect { |t| t.filename =~ /_thumb/ }
      assert !thumb.new_record?, thumb.errors.full_messages.join("\n")
      assert !thumb.size.zero?
      #assert_in_delta 4673, thumb.size, 2
      assert_equal 50,   thumb.width
      assert_equal 50,   thumb.height
      assert_equal 1.0,  thumb.aspect_ratio
      
      geo   = attachment.thumbnails.detect { |t| t.filename =~ /_geometry/ }
      assert !geo.new_record?, geo.errors.full_messages.join("\n")
      assert !geo.size.zero?
      #assert_equal 3915, geo.size
      assert_equal 50,   geo.width
      assert_equal 50,   geo.height
      assert_equal 1.0,  geo.aspect_ratio
    end
  end

  def test_should_give_correct_thumbnail_filenames
    assert_created ImageWithThumbsFileAttachment, 3 do
      attachment = upload_file :class => ImageWithThumbsFileAttachment, :filename => '/files/rails.png'
      thumb      = attachment.thumbnails.detect { |t| t.filename =~ /_thumb/ }
      geo        = attachment.thumbnails.detect { |t| t.filename =~ /_geometry/ }

      assert_match /rails\.png$/,          attachment.full_filename
      assert_match /rails_geometry\.png$/, attachment.full_filename(:geometry)
      assert_match /rails_thumb\.png$/,    attachment.full_filename(:thumb)
    end
  end

  #TODO: This is just a copy of the test above, need to find a way of making
  # assert_created Attachment, only check for a DbFile record if the attachment
  # is stored in the database
  def test_should_automatically_create_thumbnails_for_file_attachment(klass = ImageWithThumbsFileAttachment)
    assert_created klass, 3 do
      attachment = upload_file :class => klass, :filename => '/files/rails.png'
      assert !attachment.new_record?, attachment.errors.full_messages.join("\n")
      assert !attachment.size.zero?
      #assert_equal 1784, attachment.size
      
      assert_equal 55,   attachment.width
      assert_equal 55,   attachment.height
      assert_equal 2,    attachment.thumbnails.length
      assert_equal 1.0,  attachment.aspect_ratio
      
      thumb = attachment.thumbnails.detect { |t| t.filename =~ /_thumb/ }
      assert !thumb.new_record?, thumb.errors.full_messages.join("\n")
      assert !thumb.size.zero?
      #assert_in_delta 4673, thumb.size, 2
      assert_equal 50,   thumb.width
      assert_equal 50,   thumb.height
      assert_equal 1.0,  thumb.aspect_ratio
      
      geo   = attachment.thumbnails.detect { |t| t.filename =~ /_geometry/ }
      assert !geo.new_record?, geo.errors.full_messages.join("\n")
      assert !geo.size.zero?
      #assert_equal 3915, geo.size
      assert_equal 50,   geo.width
      assert_equal 50,   geo.height
      assert_equal 1.0,  geo.aspect_ratio
    end
  end
  
  def test_filesystem_size_for_file_attachment(klass = FileAttachment)
    assert_created klass, 1 do
      attachment = upload_file :class => klass, :filename => '/files/rails.png'
      assert_equal attachment.size, File.open(attachment.full_filename).stat.size
    end
  end
  
  def test_should_not_overwrite_file_attachment(klass = FileAttachment)
    assert_created klass, 2 do
      real = upload_file :class => klass, :filename => '/files/rails.png'
      assert !real.new_record?, real.errors.full_messages.join("\n")
      assert !real.size.zero?
      #assert_equal 1784,  real.size
      
      fake = upload_file :class => klass, :filename => '/files/fake/rails.png'
      assert !fake.new_record?, fake.errors.full_messages.join("\n")
      assert !fake.size.zero?
      #assert_equal 4473,  fake.size
      
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
    assert_not_created do
      attachment = upload_file :class => klass, :filename => '/files/rails.png'
      assert attachment.new_record?
      assert attachment.errors.on(:content_type)
    end
  end

  def test_should_allow_single_content_type(klass = PdfAttachment)
    assert_created Attachment do
      attachment = upload_file :class => klass, :content_type => 'pdf', :filename => '/files/rails.png'
      assert !attachment.new_record?, attachment.errors.full_messages.join("\n")
    end
  end

  def test_should_allow_single_image_content_type(klass = ImageAttachment)
    assert_created klass do
      attachment = upload_file :class => klass, :content_type => 'image/png', :filename => '/files/rails.png'
      assert !attachment.new_record?, attachment.errors.full_messages.join("\n")
    end
  end

  def test_should_allow_multiple_content_types(klass = DocAttachment)
    assert_created klass, 3 do
      attachment = upload_file :class => klass, :content_type => 'pdf', :filename => '/files/rails.png'
      assert !attachment.new_record?, attachment.errors.full_messages.join("\n")
      attachment = upload_file :class => klass, :content_type => 'doc', :filename => '/files/rails.png'
      assert !attachment.new_record?, attachment.errors.full_messages.join("\n")
      attachment = upload_file :class => klass, :content_type => 'txt', :filename => '/files/rails.png'
      assert !attachment.new_record?, attachment.errors.full_messages.join("\n")
    end
  end

  def test_should_allow_multiple_content_types_with_images(klass = ImageOrPdfAttachment)
    assert_created klass, 2 do
      attachment = upload_file :class => klass, :content_type => 'pdf', :filename => '/files/rails.png'
      assert !attachment.new_record?, attachment.errors.full_messages.join("\n")
      attachment = upload_file :class => klass, :content_type => 'image/png', :filename => '/files/rails.png'
      assert !attachment.new_record?, attachment.errors.full_messages.join("\n")
    end
  end
  
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
  
  def test_reassign_attribute_data(klass = Attachment)
    assert_created klass, 1 do
      attachment = upload_file :class => klass, :filename => '/files/rails.png'
      assert !attachment.new_record?, attachment.errors.full_messages.join("\n")
      assert attachment.attachment_data.size > 0, "no data was set"
      
      attachment.attachment_data = 'wtf'
      attachment.save
      
      assert_equal 'wtf', klass.find(attachment.id).attachment_data
    end
  end
  
  def test_no_reassign_attribute_data_on_nil(klass = Attachment)
    assert_created klass, 1 do
      attachment = upload_file :class => klass, :filename => '/files/rails.png'
      assert !attachment.new_record?, attachment.errors.full_messages.join("\n")
      assert attachment.attachment_data.size > 0, "no data was set"
      
      original = attachment.attachment_data.clone.freeze
      attachment.attachment_data = nil
      attachment.save
      
      assert_equal original, klass.find(attachment.id).attachment_data
    end
  end
  
  def test_should_store_file_attachment_in_filesystem(klass = FileAttachment)
    attachment = nil
    assert_created klass do
      attachment = upload_file :class => klass, :filename => '/files/rails.png'
      assert !attachment.new_record?, attachment.errors.full_messages.join("\n")
      assert File.exists?(attachment.full_filename), "#{attachment.full_filename} does not exist"    
    end
    attachment
  end

  def test_should_overwrite_old_contents_when_updating(klass = Attachment)
    attachment   = upload_file :class => klass, :filename => '/files/rails.png'
    assert_not_created do # no new db_file records
      attachment.filename        = 'rails2.png'
      attachment.attachment_data = IO.read(File.join(File.dirname(__FILE__), 'fixtures/files/rails.png'))
      attachment.save
    end
  end

  def test_should_overwrite_old_thumbnail_records_when_updating(klass = ImageWithThumbsAttachment)
    attachment = nil
    assert_created klass, 3 do
      attachment = upload_file :class => klass, :filename => '/files/rails.png'
    end
    assert_not_created do # no new db_file records
      attachment.filename        = 'rails2.png'
      attachment.attachment_data = IO.read(File.join(File.dirname(__FILE__), 'fixtures/files/rails.png'))
      attachment.save
    end
  end

  def test_should_delete_old_file_when_updating(klass = FileAttachment)
    attachment   = upload_file :class => klass, :filename => '/files/rails.png'
    old_filename = attachment.full_filename
    assert_not_created do
      attachment.filename        = 'rails2.png'
      attachment.attachment_data = IO.read(File.join(File.dirname(__FILE__), 'fixtures/files/rails.png'))
      attachment.save
      assert  File.exists?(attachment.full_filename), "#{attachment.full_filename} does not exist"    
      assert !File.exists?(old_filename),             "#{old_filename} still exists"
    end
  end

  def test_should_overwrite_old_thumbnail_records_when_renaming(klass = ImageWithThumbsAttachment)
    attachment = nil
    assert_created klass, 3 do
      attachment = upload_file :class => klass, :filename => '/files/rails.png'
    end
    assert_not_created do # no new db_file records
      attachment.filename = 'rails2.png'
      attachment.save
      assert !attachment.reload.size.zero?
      assert_equal 'rails2.png', attachment.filename
    end
  end

  def test_should_delete_old_file_when_renaming(klass = FileAttachment)
    attachment   = upload_file :class => klass, :filename => '/files/rails.png'
    old_filename = attachment.full_filename
    assert_not_created do
      attachment.filename        = 'rails2.png'
      attachment.save
      assert  File.exists?(attachment.full_filename), "#{attachment.full_filename} does not exist"    
      assert !File.exists?(old_filename),             "#{old_filename} still exists"
      assert !attachment.reload.size.zero?
      assert_equal 'rails2.png', attachment.filename
    end
  end

  def test_should_remove_old_thumbnail_files_when_updating(klass = ImageWithThumbsFileAttachment)
    attachment = nil
    assert_created klass, 3 do
      attachment = upload_file :class => klass, :filename => '/files/rails.png'
    end
    old_filenames = [attachment.full_filename] + attachment.thumbnails.collect(&:full_filename)
    assert_not_created do
      attachment.filename        = 'rails2.png'
      attachment.attachment_data = IO.read(File.join(File.dirname(__FILE__), 'fixtures/files/rails.png'))
      attachment.save
      new_filenames = [attachment.reload.full_filename] + attachment.thumbnails.collect { |t| t.reload.full_filename }
      new_filenames.each { |f| assert  File.exists?(f), "#{f} does not exist" }
      old_filenames.each { |f| assert !File.exists?(f), "#{f} still exists" }
    end
  end

  def test_should_delete_file_when_in_file_system_when_attachment_record_destroyed(klass = ImageWithThumbsFileAttachment)
    attachment = upload_file :class => klass, :filename => '/files/rails.png'
    filenames = [attachment.full_filename] + attachment.thumbnails.collect(&:full_filename)
    filenames.each { |f| assert  File.exists?(f),  "#{f} never existed to delete on destroy" }
    attachment.destroy
    filenames.each { |f| assert !File.exists?(f),  "#{f} still exists" }
  end
  
  def test_should_use_thumbnail_subclass(klass = ImageWithThumbsClassFileAttachment)
    assert_difference ImageThumbnail, :count do
      attachment = upload_file :class => klass, :filename => '/files/rails.png'
      assert_kind_of ImageThumbnail,  attachment.thumbnails.first
      assert_equal attachment.id,     attachment.thumbnails.first.parent.id
      assert_kind_of FileAttachment,  attachment.thumbnails.first.parent
      assert_equal 'rails_thumb.png', attachment.thumbnails.first.filename
      assert_equal attachment.thumbnails.first.full_filename, attachment.full_filename(attachment.thumbnails.first.thumbnail),
        "#full_filename does not use thumbnail class' path."
    end
  end

  def test_should_verify_image_content_types
    ['image/jpeg', 'image/pjpeg', 'image/gif', 'image/png', 'image/x-png'].each do |content_type|
      assert Attachment.image?(content_type)
    end
    ['text/plain', 'application/x-xls', 'application/xml'].each do |content_type|
      assert !Attachment.image?(content_type)
    end
  end

  def test_should_call_after_attachment_saved(klass = Attachment)
    klass.saves = 0
    assert_created klass do
      upload_file :class => klass, :filename => '/files/rails.png'
    end
    assert_equal 1, klass.saves
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
    :test_should_use_thumbnail_subclass                   => ImageWithThumbsClassFileAttachment,
    :test_should_call_after_attachment_saved              => Attachment
 }.each do |test_method, klass|
    define_method("#{test_method}_on_subclass") { send test_method, Class.new(klass) }
  end

  protected
    def upload_file(options = {})
      att = (options[:class] || Attachment).create :uploaded_data => fixture_file_upload(options[:filename], options[:content_type] || 'image/png')
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
    
    def assert_not_created
      assert_created Attachment, 0 do
        yield
      end
    end
    
    def should_reject_by_size_with(klass)
      assert_not_created do
        attachment = upload_file :class => klass, :filename => '/files/rails.png'
        assert attachment.new_record?
        assert attachment.errors.on(:size)
        assert_nil attachment.db_file if attachment.respond_to?(:db_file)
      end
    end
end
