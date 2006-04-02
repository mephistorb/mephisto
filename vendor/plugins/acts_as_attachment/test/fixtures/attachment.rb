class Attachment < ActiveRecord::Base
  acts_as_attachment
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
  acts_as_attachment :thumbnails => { :thumb => [50, 50], :geometry => 'x50' }
end

class FileAttachment < ActiveRecord::Base
  acts_as_attachment :storage => :file_system, :file_system_path => 'vendor/plugins/acts_as_attachment/test/files'
end

class ImageFileAttachment < FileAttachment
  acts_as_attachment :storage => :file_system, :file_system_path => 'vendor/plugins/acts_as_attachment/test/files', 
    :content_type => :image, :resize_to => [50,50]
end

class ImageWithThumbsFileAttachment < FileAttachment
  acts_as_attachment :storage => :file_system, :file_system_path => 'vendor/plugins/acts_as_attachment/test/files',
    :thumbnails => { :thumb => [50, 50], :geometry => 'x50' }
end