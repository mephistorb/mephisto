require File.join(RAILS_ROOT, 'app/models/asset')
class Asset < ActiveRecord::Base
  def full_filename(thumbnail = nil)
    file_system_path = (thumbnail ? thumbnail_class : self).attachment_options[:file_system_path]
    File.join(base_path, 'assets', permalink, thumbnail_name_for(thumbnail))
  end

  def base_path
    @base_path ||= File.join(RAILS_ROOT, 'test/fixtures/tmp')
  end
  
  class << self
    public :types_to_conditions
  end
end
