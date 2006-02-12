# The base model for all assets.  It acts slightly different depending on what it is attached to.
# If it's a Site Asset, it is used for adding images to articles.
# If it's a User Asset, it's a profile image.
# Template and Resource inherit from Asset but serve different purposes.
class Asset < ActiveRecord::Base
  acts_as_attachment
  validate :path_exists_and_valid?

  class << self
    def find_with_data(quantity, options = {})
      find quantity, options.merge(:select => 'assets.*, db_files.data', :joins => 'LEFT OUTER JOIN db_files ON assets.db_file_id = db_files.id')
    end
  end

  def full_path
    File.join(path, filename)
  end

  # Read from the model's attributes if it's available.
  def data
    read_attribute(:data) || (db_file_id ? db_file.data : nil)
  end

  # set the model's data attribute and attachment_data
  def data=(value)
    write_attribute :data, value
    self.attachment_data = value
  end

  def path_exists_and_valid?
    path.blank? ? 
      errors.add(:path, ActiveRecord::Errors.default_error_messages[:blank]) :
      self.path.gsub!(/^\/+|\/+$/, '')
  end
end
