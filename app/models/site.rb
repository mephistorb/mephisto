class Site < ActiveRecord::Base
  has_many  :sections
  has_many  :articles
  has_many  :drafts, :class_name => 'Article::Draft', :order => 'content_drafts.updated_at'
  has_many  :events
  
  has_many  :assets, :as => :attachable
  has_many  :templates
  has_many  :resources
  has_many  :attachments, :extend => Theme
  
  serialize :filters, Array
  
  before_validation_on_create :set_default_comment_options
  validates_uniqueness_of :host

  with_options :order => 'created_at', :class_name => 'Comment' do |comment|
    comment.has_many :comments,            :conditions => ['contents.approved = ?', true]
    comment.has_many :unapproved_comments, :conditions => ['contents.approved = ?', false]
    comment.has_many :all_comments
  end

  def filters=(value)
    write_attribute :filters, [value].flatten.collect(&:to_sym)
  end

  def to_liquid
    {
      'title'    => title, 
      'subtitle' => subtitle,
      'host'     => host
    }
  end

  protected
    def set_default_comment_options
      self.accept_comments  = true  unless accept_comments == false
      self.approve_comments = false unless approve_comments?
      self.comment_age      = 30    unless comment_age
      true
    end
end
