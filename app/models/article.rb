class Article < Content
  class CommentNotAllowed < StandardError; end
  
  include Mephisto::TaggableMethods
  
  validates_presence_of :title, :user_id, :site_id

  before_validation { |record| record.set_default_filter! }
  after_validation :convert_to_utc
  before_create :create_permalink
  before_save   :pass_filter_to_comments
  after_save    :save_assigned_sections

  acts_as_versioned :if_changed => [:title, :body, :excerpt], :limit => 5 do
    def self.included(base)
      base.belongs_to :updater, :class_name => '::User', :foreign_key => 'updater_id'
    end

    def published?
      !new_record? && !published_at.nil?
    end
  end

  has_many :assigned_sections, :dependent => :destroy
  has_many :sections, :through => :assigned_sections, :order => 'sections.name'
  has_many :events,   :order => 'created_at desc', :dependent => :delete_all
  with_options :order => 'created_at', :class_name => 'Comment' do |comment|
    comment.has_many :comments,            :conditions => ['contents.approved = ?', true], :dependent => :delete_all  do
      def unapprove(id)
        returning find(id) do |comment|
          comment.approved = false
          comment.save
        end
      end
    end
    comment.has_many :unapproved_comments, :conditions => ['contents.approved = ?', false] do
      def approve(id)
        returning find(id) do |comment|
          comment.approved = true
          comment.save
        end
      end
    end
    comment.has_many :all_comments
  end

  class << self
    def approve
      comment = @article.unapproved_comments.find(params[:comment])
      comment.approved = true
      comment.save
    end
    
    def unapprove
      comment = @article.comments.find(params[:comment])
      comment.approved = false
      comment.save
    end
  end

  class << self
    def find_by_permalink(year, month, day, permalink, options = {})
      from, to = Time.delta(year, month, day)
      find :first, options.merge(:conditions => ["contents.published_at <= ? AND contents.permalink = ? AND contents.published_at BETWEEN ? AND ?", 
        Time.now.utc, permalink, from, to])
    end
    
    def find_all_by_published_date(year, month, day = nil, options = {})
      from, to = Time.delta(year, month, day)
      find(:all, options.merge(:order => 'contents.published_at DESC', :conditions => ["contents.published_at <= ? AND contents.published_at BETWEEN ? AND ?", 
        Time.now.utc, from, to]))
    end

    def count_by_published_date(year, month, day = nil)
      from, to = Time.delta(year, month, day)
      count :all, :conditions => ["published_at <= ? AND published_at BETWEEN ? AND ?", Time.now.utc, from, to]
    end
  end
  
  def pending?
    published? && Time.now.utc < published_at
  end

  def status
    pending? ? :pending : :published
  end

  # Follow Mark Pilgrim's rules on creating a good ID
  # http://diveintomark.org/archives/2004/05/28/howto-atom-id
  def guid
    "/#{self.class.to_s.underscore}#{full_permalink}"
  end

  def full_permalink
    ['', published_at.year, published_at.month, published_at.day, permalink] * '/'
  end

  def has_section?(section)
    (new_record? && section.home?) || sections.include?(section)
  end

  def section_ids=(new_sections)
    @new_sections = new_sections
  end

  # :mode - single / list.  Specifies whether the body is only the excerpt or not
  # :page - true / false.  Specifies whether the article is the main section page.
  def to_liquid(options = {})
    Mephisto::Liquid::ArticleDrop.new self, options
  end

  def filter=(new_filter)
    return if new_filter == read_attribute(:filter)
    @old_filter ||= read_attribute(:filter)
    write_attribute :filter, new_filter
  end

  def hash_for_permalink(options = {})
    { :year      => published_at.year, 
      :month     => published_at.month, 
      :day       => published_at.day, 
      :permalink => permalink }.merge(options)
  end

  def accept_comments?
    status == :published && (comment_age > -1) && (comment_age == 0 || comments_expired_at > Time.now.utc)
  end

  def comments_expired_at
    published_at + comment_age.days
  end

  def set_filter_from(filtered_object)
    self.filter = filtered_object.filter
  end

  def set_default_filter_from(filtered_object)
    set_filter_from(filtered_object) if filter.blank?
  end

  def set_default_filter!
    set_default_filter_from user
  end

  protected
    def create_permalink
      self.permalink = title.to_s.gsub(/\W+/, ' ').strip.downcase.gsub(/\ +/, '-')
    end

    def convert_to_utc
      self.published_at = published_at.utc if published_at
    end
    
    def save_assigned_sections
      return if @new_sections.nil?
      assigned_sections.each do |assigned_section|
        @new_sections.delete(assigned_section.section_id.to_s) || assigned_section.destroy
      end
      
      if !@new_sections.blank?
        Section.find(:all, :conditions => ['id in (?)', @new_sections]).each { |section| assigned_sections.create :section => section }
        sections.reset
      end
    
      @new_sections = nil
    end
    
    def body_for_mode(mode = :list)
      (mode == :single ? [body_html, excerpt_html] : [excerpt_html, body_html]).detect { |attr| !attr.blank? }.to_s.strip
    end
    
    def pass_filter_to_comments
      return unless @old_filter
      self.record_timestamps  = false
      CommentObserver.disabled = true
      comments.each { |c| c.update_attributes(:filter => filter) }
      @old_filter = nil
      true
    ensure
      self.record_timestamps   = true
      CommentObserver.disabled = false
    end
end