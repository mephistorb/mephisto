class Article < Content
  validates_presence_of :title, :user_id

  before_create :create_permalink
  before_create :set_filter_from_user
  after_save    :save_assigned_sections

  acts_as_versioned :if_changed => [:title, :body, :excerpt] do
    def self.included(base)
      base.belongs_to :updater, :class_name => '::User', :foreign_key => 'updater_id'
    end
  end

  has_many :assigned_sections
  has_many :sections, :through => :assigned_sections, :order => 'sections.name'
  has_many :comments, :order   => 'created_at'
  has_many :events,   :order => 'created_at desc'
  
  class << self
    def find_by_permalink(year, month, day, permalink)
      from, to = Time.delta(year, month, day)
      find :first, :conditions => ["published_at <= ? AND permalink = ? AND published_at BETWEEN ? AND ?", 
        Time.now.utc, permalink, from, to]
    end
    
    def find_all_by_published_date(year, month, day = nil, options = {})
      from, to = Time.delta(year, month, day)
      find(:all, options.merge(:order => 'published_at DESC', :conditions => ["published_at <= ? AND published_at BETWEEN ? AND ?", 
        Time.now.utc, from, to]))
    end

    def count_by_published_date(year, month, day = nil)
      from, to = Time.delta(year, month, day)
      count ["published_at <= ? AND published_at BETWEEN ? AND ?", Time.now.utc, from, to]
    end
  end

  def published_at=(new_published_at)
    @recently_published = published_at.nil? && !new_published_at.nil?
    write_attribute :published_at, new_published_at
  end

  def recently_published?
    @recently_published == true
  end

  def published?
    !published_at.nil?
  end
  
  def pending?
    published? && Time.now.utc < published_at
  end

  def status
    return :unpublished unless published?
    return :pending     if     pending?
    :published
  end

  # Follow Mark Pilgrim's rules on creating a good ID
  # http://diveintomark.org/archives/2004/05/28/howto-atom-id
  def guid
    "/#{self.class.to_s.underscore}/#{published_at.year}/#{published_at.month}/#{published_at.day}/#{permalink}"
  end

  def has_section?(section)
    (new_record? and section.name == 'home') or sections.include? section
  end

  def section_ids=(new_sections)
    @new_sections = new_sections
  end

  def to_liquid(mode = :list)
    { 'id'             => id,
      'title'          => title,
      'permalink'      => permalink,
      'url'            => full_permalink,
      'body'           => body_for_mode(mode),
      'published_at'   => published_at,
      'comments_count' => comments_count }
  end

  def hash_for_permalink(options = {})
    { :year      => published_at.year, 
      :month     => published_at.month, 
      :day       => published_at.day, 
      :permalink => permalink }.merge(options)
  end

  def full_permalink
    ['', published_at.year, published_at.month, published_at.day, permalink].join('/')
  end

  protected
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

    @new_sections       = nil
    @recently_published = nil
  end

  def body_for_mode(mode = :list)
    (mode == :single ? excerpt_html.to_s + "\n\n" + body_html.to_s : (excerpt_html || body_html)).strip
  end
end