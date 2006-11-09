class Attachment < ActiveRecord::Base
  @@saves = 0
  cattr_accessor :saves
  acts_as_attachment
  validates_as_attachment
  after_attachment_saved do |record|
    self.saves += 1
  end
end

class SmallAttachment < Attachment
  acts_as_attachment :max_size => 1.kilobyte
end

class BigAttachment < Attachment
  acts_as_attachment :size => 1.megabyte..2.megabytes
end

class PdfAttachment < Attachment
  acts_as_attachment :content_type => 'pdf'
end

class DocAttachment < Attachment
  acts_as_attachment :content_type => %w(pdf doc txt)
end

class ImageAttachment < Attachment
  acts_as_attachment :content_type => :image, :resize_to => [50,50]
end

class ImageOrPdfAttachment < Attachment
  acts_as_attachment :content_type => ['pdf', :image], :resize_to => 'x50'
end

class ImageWithThumbsAttachment < Attachment
  acts_as_attachment :thumbnails => { :thumb => [50, 50], :geometry => 'x50' }, :resize_to => [55,55]
  after_resize do |record, img|
    record.aspect_ratio = img.columns.to_f / img.rows.to_f
  end
end

class FileAttachment < ActiveRecord::Base
  acts_as_attachment :file_system_path => 'vendor/plugins/acts_as_attachment/test/files'
  validates_as_attachment
end

class ImageFileAttachment < FileAttachment
  acts_as_attachment :file_system_path => 'vendor/plugins/acts_as_attachment/test/files', 
    :content_type => :image, :resize_to => [50,50]
end

class ImageWithThumbsFileAttachment < FileAttachment
  acts_as_attachment :file_system_path => 'vendor/plugins/acts_as_attachment/test/files',
    :thumbnails => { :thumb => [50, 50], :geometry => 'x50' }, :resize_to => [55,55]
  after_resize do |record, img|
    record.aspect_ratio = img.columns.to_f / img.rows.to_f
  end
end

class ImageWithThumbsClassFileAttachment < FileAttachment
  acts_as_attachment :file_system_path => 'vendor/plugins/acts_as_attachment/test/files',
    :thumbnails => { :thumb => [50, 50] }, :resize_to => [55,55],
    :thumbnail_class => 'ImageThumbnail'
end

class ImageThumbnail < FileAttachment
  acts_as_attachment :file_system_path => 'vendor/plugins/acts_as_attachment/test/files/thumbnails'
end

# no parent
class OrphanAttachment < ActiveRecord::Base
  acts_as_attachment
  validates_as_attachment
end

# no filename, no size, no content_type
class MinimalAttachment < ActiveRecord::Base
  acts_as_attachment :file_system_path => 'vendor/plugins/acts_as_attachment/test/files'
  validates_as_attachment
  
  def filename
    "#{id}.file"
  end
end