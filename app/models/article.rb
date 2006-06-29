class Article < Content
  validates_presence_of :title, :user_id, :site_id

  after_validation :set_comment_expiration
  before_create :create_permalink
  before_create :set_filter_from_user
  after_save    :save_assigned_sections

  acts_as_versioned :if_changed => [:title, :body, :excerpt] do
    def self.included(base)
      base.belongs_to :updater, :class_name => '::User', :foreign_key => 'updater_id'
    end
  end

  acts_as_draftable :fields => [:title, :body, :excerpt, :site_id] do
    def self.included(base)
      base.validates_presence_of :site_id
    end
  end

  has_many :assigned_sections
  has_many :sections, :through => :assigned_sections, :order => 'sections.name'
  has_many :events,   :order => 'created_at desc'
  with_options :order => 'created_at',:class_name => 'Comment' do |comment|
    comment.has_many :comments,            :conditions => ['contents.approved = ?', true]  do
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

  def published?
    !published_at.nil?
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
    (new_record? && section.name == 'home') || sections.include?(section)
  end

  def section_ids=(new_sections)
    @new_sections = new_sections
  end

  def to_liquid(mode = :list)
    Mephisto::Liquid::ArticleDrop.new self, mode
  end

  def hash_for_permalink(options = {})
    { :year      => published_at.year, 
      :month     => published_at.month, 
      :day       => published_at.day, 
      :permalink => permalink }.merge(options)
  end

  def comments_expired?
    expire_comments_at && expire_comments_at > Time.now.utc
  end

  protected
    def set_comment_expiration
      if site.accept_comments?
        self.expire_comments_at = published_at + site.comment_age.days if site.comment_age.to_i > 0
      else
        self.expire_comments_at = published_at
      end unless !errors.empty? || published_at.nil? || expire_comments_at
    end
  
    def create_permalink
      self.permalink = title.strip.downcase \
        .gsub(/['"]/, '')                   \
        .gsub(/(\W|\ )+/, '-')              \
        .chomp('-').reverse.chomp('-').reverse
    end
    
    def set_filter_from_user
      self.filters = user.filters if filters.nil?
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
      (mode == :single ? excerpt_html.to_s + "\n\n" + body_html.to_s : (excerpt_html || body_html)).strip
    end
end