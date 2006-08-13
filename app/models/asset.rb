class Asset < ActiveRecord::Base
  # used for extra mime types that dont follow the convention
  @@extra_content_types = { :audio => ['application/ogg'] }
  cattr_reader :extra_content_types

  class << self
    def movie?(content_type)
      content_type.to_s =~ /^video/
    end
    
    def audio?(content_type)
      content_type.to_s =~ /^audio/ || extra_content_types[:audio].include?(content_type)
    end
    
    def document?(content_type)
      !image?(content_type) && !movie?(content_type) && !audio?(content_type)
    end
  end

  belongs_to :site
  acts_as_attachment :storage => :file_system, :thumbnails => { :thumb => '120>', :tiny => '50>' }
  before_validation_on_create :set_site_from_parent
  validates_presence_of :site_id
  validates_as_attachment

  def full_filename(thumbnail = nil)
    file_system_path = (thumbnail ? thumbnail_class : self).attachment_options[:file_system_path]
    File.join(RAILS_ROOT, 'public/assets', permalink, thumbnail_name_for(thumbnail))
  end

  def public_filename_with_host(thumbnail = nil)
    returning public_filename_without_host(thumbnail) do |s|
      s.gsub! /^\/assets\/[^\/]+\//, "/assets/#{$1}" if Site.multi_sites_enabled
    end
  end
  alias_method_chain :public_filename, :host

  [:movie, :audio, :document].each do |content|
    define_method("#{content}?") { self.class.send("#{content}?", content_type) }
  end

  protected
    def permalink
      pieces = [site.host, created_at.year, created_at.month, created_at.day]
      pieces.shift unless Site.multi_sites_enabled
      pieces * '/'
    end
    
    def set_site_from_parent
      self.site_id = parent.site_id if parent_id
    end
end
