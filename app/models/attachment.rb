# Base file attachment method
class Attachment < ActiveRecord::Base  
  before_validation :sanitize_path_if_available
  acts_as_attachment

  class << self    
    def find_with_data(quantity, options = {})
      find quantity, options.merge(:select => 'attachments.*, db_files.data', :joins => 'LEFT OUTER JOIN db_files ON attachments.db_file_id = db_files.id')
    end
  end

  def full_path
    File.join(path, filename)
  end

  module TemplateAndResourceMixin
    def self.included(base)
      base.validate :path_exists_and_valid?
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

    protected
    def path_exists_and_valid?
      errors.add(:path, ActiveRecord::Errors.default_error_messages[:blank]) if path.blank?
    end
  end

  protected
  def sanitize_path_if_available
    self.path.gsub!(/^\/+|\/+$/, '') unless path.blank?
  end
end