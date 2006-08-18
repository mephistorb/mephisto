class Asset < ActiveRecord::Base
  # used for extra mime types that dont follow the convention
  @@extra_content_types = { :audio => ['application/ogg'], :movie => ['application/x-shockwave-flash'] }
  @@extra_content_types.each { |k, values| values.each &:freeze }
  cattr_reader :extra_content_types

  @@movie_condition = sanitize_sql ['content_type LIKE ? OR content_type IN (?)', 'video%', extra_content_types[:movie]]
  @@audio_condition = sanitize_sql ['content_type LIKE ? OR content_type IN (?)', 'audio%', extra_content_types[:audio]]
  @@image_condition = sanitize_sql ['content_type IN (?)', Technoweenie::ActsAsAttachment.content_types]
  @@other_condition = sanitize_sql [
    'content_type NOT LIKE ? AND content_type NOT LIKE ? AND content_type NOT IN (?)',
    'audio%', 'video%', (extra_content_types[:movie] + extra_content_types[:audio] + Technoweenie::ActsAsAttachment.content_types)]
  cattr_reader *%w(movie audio image other).collect! { |t| "#{t}_condition".to_sym }

  class << self
    def movie?(content_type)
      content_type.to_s =~ /^video/ || extra_content_types[:movie].include?(content_type)
    end
    
    def audio?(content_type)
      content_type.to_s =~ /^audio/ || extra_content_types[:audio].include?(content_type)
    end
    
    def other?(content_type)
      ![:image, :movie, :audio].any? { |a| send("#{a}?", content_type) }
    end

    def find_all_by_content_types(types, *args)
      with_scope(:find => { :conditions => types_to_conditions(types).join(' OR ') }) { find *args }
    end
    
    protected
      def types_to_conditions(types)
        types.collect! { |t| '(' + send("#{t}_condition") + ')' }
      end
  end

  belongs_to :site
  has_many :taggings, :as => :taggable
  has_many :tags, :through => :taggings, :order => 'tags.name'
  acts_as_attachment :storage => :file_system, :thumbnails => { :thumb => '120>', :tiny => '50>' }, :max_size => 30.megabytes
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

  [:movie, :audio, :other].each do |content|
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
