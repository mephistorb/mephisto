class Avatar < Asset
  after_validation :set_path_and_filename

  protected
  def set_path_and_filename
    self.path     = 'images/users'
    self.filename = "#{attachable.login}.#{filename.to_s.split('.').last}"
  end
end