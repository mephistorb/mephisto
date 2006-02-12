class Asset < ActiveRecord::Base
  acts_as_attachment

  class << self
    def find_with_data(quantity, options = {})
      find quantity, options.merge(:select => 'assets.*, db_files.data', :joins => 'LEFT OUTER JOIN db_files ON assets.db_file_id = db_files.id')
    end
  end
end
