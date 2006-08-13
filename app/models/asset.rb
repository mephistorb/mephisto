class Asset < ActiveRecord::Base
  belongs_to :site
  acts_as_attachment :storage => :file_system, :thumbnails => { :thumb => '120>', :tiny => '50>' }
  before_validation_on_create :set_site_from_parent
  validates_presence_of :site_id
  validates_as_attachment

  def full_filename(thumbnail = nil)
    file_system_path = (thumbnail ? thumbnail_class : self).attachment_options[:file_system_path]
    File.join(RAILS_ROOT, 'public/assets', site.host, date_to_permalink, thumbnail_name_for(thumbnail))
  end
  
  protected
    def date_to_permalink
      [created_at.year, created_at.month, created_at.day] * '/'
    end
    
    def set_site_from_parent
      self.site_id = parent.site_id if parent_id
    end
end
