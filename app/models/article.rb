class Article < Content
  class CommentNotAllowed < StandardError; end
  
  validates_presence_of :title, :user_id, :site_id

  before_validation { |record| record.set_default_filter! }
  after_validation :convert_to_utc
  before_create :create_permalink
  after_save    :save_assigned_sections

  acts_as_versioned :if_changed => [:title, :body, :excerpt], :limit => 5 do
    def self.included(base)
      base.send :include, Mephisto::TaggableMethods
      base.belongs_to :updater, :class_name => '::User', :foreign_key => 'updater_id', :with_deleted => true
      [:year, :month, :day].each { |m| base.delegate m, :to => :published_at }
    end

    def published?
      !new_record? && !published_at.nil?
    end

    def pending?
      !published? || Time.now.utc < published_at
    end
    
    def status
      pending? ? :pending : :published
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
    def find_by_date(options = {})
      find(:all, { :order => 'contents.published_at desc', 
                   :conditions => ['contents.published_at <= ? AND contents.published_at IS NOT NULL', Time.now.utc] } \
        .merge(options))
    end
    
    def find_all_in_month(year, month, options = {})
      find(:all, options.merge(:order => 'contents.published_at DESC', :conditions => ["contents.published_at <= ? AND contents.published_at BETWEEN ? AND ?", 
        Time.now.utc, *Time.delta(year.to_i, month.to_i)]))
    end
    
    def find_all_by_tags(tag_names, limit = 15)
      find(:all, :order => 'contents.published_at DESC', :include => [:tags, :user], :limit => limit,
        :conditions => ['(contents.published_at <= ? AND contents.published_at IS NOT NULL) AND tags.name IN (?)', Time.now.utc, tag_names])
    end
    
    def permalink_for(str)
      str.gsub(/\W+/, ' ').strip.downcase.gsub(/\ +/, '-')
    end
  end

  # AX
  def full_permalink
    published? && ['', published_at.year, published_at.month, published_at.day, permalink] * '/'
  end

  def has_section?(section)
    return @new_sections.include?(section.id.to_s) if !@new_sections.blank?
    (new_record? && section.home?) || sections.include?(section)
  end

  def section_ids=(new_sections)
    @new_sections = new_sections
  end

  def published_at=(value)
    @recently_published = published_at.nil? && value
    write_attribute :published_at, value
  end
  
  def recently_published?
    @recently_published
  end

  # :mode - single / list.  Specifies whether the body is only the excerpt or not
  # :page - true / false.  Specifies whether the article is the main section page.
  def to_liquid(options = {})
    ArticleDrop.new self, options
  end

  def filter=(new_filter)
    return if new_filter == read_attribute(:filter)
    @old_filter ||= read_attribute(:filter)
    write_attribute :filter, new_filter
  end

  # AX
  def hash_for_permalink(options = {})
    [:year, :month, :day, :permalink].inject(options) { |o, a| o.update a => send(a) }
  end

  def accept_comments?
    status == :published && (comment_age > -1) && (comment_age == 0 || comments_expired_at > Time.now.utc)
  end

  def comments_expired_at
    (published_at || Time.now.utc) + comment_age.days
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
      self.permalink = self.class.permalink_for(title.to_s) if permalink.blank?
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
end