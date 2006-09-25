require 'uri'

class Comment < Content
  validates_presence_of :author, :author_ip, :article_id, :body
  validates_format_of :author_email, :with => Format::EMAIL
  before_validation :clean_up_author_email
  before_validation :clean_up_author_url
  after_validation_on_create  :snag_article_attributes
  before_create  :check_comment_expiration
  before_save    :update_counter_cache
  before_destroy :decrement_counter_cache
  belongs_to :article
  has_one :event, :dependent => :destroy
  attr_protected :approved

  def self.find_all_by_section(section, options = {})
    find :all, options.update(:conditions => ['contents.approved = ? and assigned_sections.section_id = ?', true, section.id], 
      :select => 'contents.*', :joins => 'INNER JOIN assigned_sections ON assigned_sections.article_id = contents.article_id', 
      :order  => 'contents.created_at DESC')
  end

  def to_liquid
    CommentDrop.new self
  end
  
  def approved=(value)
    @old_approved ||= approved? ? :true : :false
    write_attribute :approved, value
  end

  def clean_up_author_email
    if value = read_attribute(:author_email) then
      write_attribute :author_email, value.strip
    end
  end

  def clean_up_author_url
    if value = read_attribute(:author_url) then
      value.strip!
      value = 'http://' + value unless value.blank? || value[0..0] == '/' || URI::parse(value).scheme
      write_attribute :author_url, value
    end
  end

  protected
    def snag_article_attributes
      self.attributes = { :site => article.site, :filter => article.site.filter, :title => article.title, :published_at => article.published_at, :permalink => article.permalink }
    end

    def check_comment_expiration
      raise Article::CommentNotAllowed unless article.accept_comments?
    end

    def update_counter_cache
      Article.increment_counter 'comments_count', article_id if  approved? && @old_approved == :false
      Article.decrement_counter 'comments_count', article_id if !approved? && @old_approved == :true
    end
    
    def decrement_counter_cache
      Article.decrement_counter 'comments_count', article_id if approved?
    end
end
