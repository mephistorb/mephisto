class Avatar < Asset
  after_validation :set_path_and_filename
  acts_as_attachment :content_type => :image, :resize_to => '75x75>'

  protected
  def set_path_and_filename
    self.path     = 'images/users'
    self.filename = "#{attachable.login}.#{filename.to_s.split('.').last}"
  end
end