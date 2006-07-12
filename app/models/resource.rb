# A Resource is a special type of Asset for files relating to the current theme.
# This includes css, javascript, and images.
class Resource < Attachment
  before_validation  :set_file_path_and_extension
  acts_as_attachment :content_type => ['text/css', 'text/javascript', :image]
  validates_as_attachment

  class << self
    def find_image(filename)
      find :first, :conditions => ['filename = ? and content_type not in (?)', filename, content_ext.keys]
    end
  end

  def full_filename(thumbnail = nil)
    File.join(base_path, path, thumbnail_name_for(thumbnail).to_s)
  end

  def base_path
    @base_path ||= File.join(RAILS_ROOT, 'themes', "site-#{site_id}")
  end

  def path
    content_path[content_type] || 'images'
  end
  
  def extension
    content_ext[content_type]
  end

  def image?
    ! content_ext.keys.include?(content_type)
  end

  protected
    def set_file_path_and_extension
      self.filename += extension unless filename.blank? || image? || filename =~ /\.(css|js)$/
    end
end
