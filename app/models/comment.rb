require 'uri'

class Comment < Content
  validates_presence_of :author, :author_ip, :article_id, :body
  validates_format_of :author_email, :with => Format::EMAIL
  before_validation :clean_up_author_email
  before_validation :clean_up_author_url
  after_validation_on_create  :snag_article_attributes
  before_create  :check_comment_expiration
  before_create  :sanitize_attributes
  before_save    :update_counter_cache
  before_destroy :decrement_counter_cache
  belongs_to :article
  has_one :event, :dependent => :destroy
  before_create  :check_if_previewing

  serialize :spam_engine_data, Hash

  attr_accessible :article, :article_id, :user_id, :user, :excerpt, :body, :author, :author_url, :author_email, :author_ip, :updater_id, :updater, :comment_age, :user_agent, :referrer, :preview
  attr_accessor :preview
  class Previewing < StandardError; end

  # If the view sends the "preview" accessor, we raise this
  # error so the controller can simply rescue 
  def check_if_previewing
    raise Comment::Previewing if preview
  end
  
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
  rescue URI::InvalidURIError
    write_attribute :author_url, nil
  end

  def article_referenced_cache_key
    "[#{article_id}:Article]"
  end

  def check_approval(site, request)
    self.approved = site.approve_comments? || spam_engine(site).ham?(self, request)
  end

  def mark_as_spam(site, request)
    spam_engine(site).mark_as_spam(self, request)
  end
  
  def mark_as_ham(site, request)
    spam_engine(site).mark_as_ham(self, request)
  end

  protected
    def spam_engine(site)
      site.spam_engine
    end

    def sanitize_attributes
      [:author, :author_url, :author_email, :author_ip, :user_agent, :referrer].each do |a|
        self.send("#{a}=", CGI::escapeHTML(self.send(a).to_s))
      end
    end

    def snag_article_attributes
      self.filter ||= article.site.filter
      [:site, :title, :published_at, :permalink].each { |a| self.send("#{a}=", article.send(a)) }
    end

    def check_comment_expiration
      raise Article::CommentNotAllowed, "#{article.status} does not allow comments" unless article.accept_comments?
    end

    def update_counter_cache
      Article.increment_counter 'comments_count', article_id if  approved? && @old_approved == :false
      Article.decrement_counter 'comments_count', article_id if !approved? && @old_approved == :true
    end
    
    def decrement_counter_cache
      Article.decrement_counter 'comments_count', article_id if approved?
    end
end
