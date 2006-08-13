class Site < ActiveRecord::Base
  has_many  :sections do
    def home
      Section.find_by_path 'home'
    end
  end

  has_many  :articles
  has_many  :events
  
  has_many  :assets, :as => :attachable
  has_many  :templates
  has_many  :resources
  has_many  :attachments, :extend => Theme
  has_many  :assets, :order => 'created_at desc', :conditions => 'parent_id is null'
  
  serialize :filters, Array
  
  before_validation :set_default_timezone
  before_validation_on_create :set_default_comment_options
  validates_uniqueness_of :host

  with_options :order => 'contents.created_at', :class_name => 'Comment' do |comment|
    comment.has_many :comments,            :conditions => ['contents.approved = ?', true]
    comment.has_many :unapproved_comments, :conditions => ['contents.approved = ? or contents.approved is null', false]
    comment.has_many :all_comments
  end

  def accept_comments?
    comment_age.to_i > -1
  end

  def to_liquid(current_section = nil)
    Mephisto::Liquid::SiteDrop.new self, current_section
  end

  def filters=(value)
    write_attribute :filters, [value].flatten.collect { |v| v.blank? ? nil : v.to_sym }.compact.uniq
  end

  composed_of :timezone, :class_name => 'TZInfo::Timezone', :mapping => %w(timezone name)
  alias original_timezone_writer timezone=
  def timezone=(name)
    name = TZInfo::Timezone.new(name) unless name.is_a?(TZInfo::Timezone)
    original_timezone_writer(name)
  end

  protected
    def set_default_timezone
      self.timezone = 'UTC' if read_attribute(:timezone).blank?
      true
    end

    def set_default_comment_options
      self.approve_comments = false unless approve_comments?
      self.comment_age      = 30    unless comment_age
      true
    end
end
