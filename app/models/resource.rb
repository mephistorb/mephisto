# A Resource is a special type of Asset for files relating to the current theme.
# This includes css, javascript, and images.
class Resource < Asset
  @@content_path = { 'text/css' => 'stylesheets', 'text/javascript' => 'javascripts' }
  @@content_ext  = { 'text/css' => '.css',        'text/javascript' => '.js' }
  cattr_accessor :content_path, :content_ext

  acts_as_attachment :content_type => ['text/css', 'text/javascript', :image]
  before_validation  :set_file_path_and_extension

  protected
  def set_file_path_and_extension
    self.path      = content_path[content_type] || 'images'
    self.filename += content_ext[content_type] unless filename.blank? or image? or filename =~ /\.(css|js)$/
  end
end
