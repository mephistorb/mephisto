require File.join(RAILS_ROOT, 'app/models/asset')
class Asset < ActiveRecord::Base
  def full_filename(thumbnail = nil)
    file_system_path = (thumbnail ? thumbnail_class : self).attachment_options[:file_system_path]
    File.join(RAILS_ROOT, 'test/fixtures/assets/tmp', site.host, date_to_permalink, thumbnail_name_for(thumbnail))
  end
end
