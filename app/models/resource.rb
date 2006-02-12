class Resource < Asset
  @@content_path = { 'text/css' => 'stylesheets', 'text/javascript' => 'javascripts' }
  @@content_ext  = { 'text/css' => '.css',        'text/javascript' => '.js' }
  cattr_accessor :content_path, :content_ext

  acts_as_attachment :content_type => ['text/css', 'text/javascript']
  before_validation  :set_file_path_and_extension

  protected
  def set_file_path_and_extension
    self.path      = content_path[content_type]
    self.filename += content_ext[content_type] unless filename =~ /\.(css|js)$/
  end
end
