class Site < ActiveRecord::Base
  has_many  :sections do
    def home
      Section.find_by_name 'home'
    end
  end

  has_many  :articles
  has_many  :drafts, :class_name => 'Article::Draft', :order => 'content_drafts.updated_at'
  has_many  :events
  
  has_many  :assets, :as => :attachable
  has_many  :templates
  has_many  :resources
  has_many  :attachments, :extend => Theme
  
  serialize :filters, Array
  
  before_validation_on_create :set_default_options
  validates_uniqueness_of :host

  with_options :order => 'contents.created_at', :class_name => 'Comment' do |comment|
    comment.has_many :comments,            :conditions => ['contents.approved = ?', true]
    comment.has_many :unapproved_comments, :conditions => ['contents.approved = ?', false]
    comment.has_many :all_comments
  end

  def to_liquid
    {
      'title'    => title, 
      'subtitle' => subtitle,
      'host'     => host
    }
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
    def set_default_options
      self.accept_comments  = true  unless accept_comments == false
      self.approve_comments = false unless approve_comments?
      self.comment_age      = 30    unless comment_age
      self.timezone         = 'UTC' if timezone.blank?
      true
    end
end
