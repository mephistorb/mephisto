class Asset < ActiveRecord::Base
  acts_as_attachment
  alias_method :data=, :attachment_data=
  validate :path_exists_and_valid?

  class << self
    def find_with_data(quantity, options = {})
      find quantity, options.merge(:select => 'assets.*, db_files.data', :joins => 'LEFT OUTER JOIN db_files ON assets.db_file_id = db_files.id')
    end
  end

  def full_path
    File.join(path, filename)
  end

  def data
    read_attribute(:data) || (db_file_id ? db_file.data : nil)
  end

  def path_exists_and_valid?
    path.blank? ? 
      errors.add(:path, ActiveRecord::Errors.default_error_messages[:blank]) :
      self.path.gsub!(/^\/+|\/+$/, '')
  end
end
