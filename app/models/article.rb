class Article < Content
  validates_presence_of :title, :user_id

  before_create :create_permalink
  after_save    :save_assigned_sections

  has_many :assigned_sections
  has_many :sections, :through => :assigned_sections, :order => 'sections.name'
  has_many :comments, :order   => 'created_at'
  
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

  # Follow Mark Pilgrim's rules on creating a good ID
  # http://diveintomark.org/archives/2004/05/28/howto-atom-id
  def guid
    "/#{self.class.to_s.underscore}/#{published_at.year}/#{published_at.month}/#{published_at.day}/#{permalink}"
  end

  def published?
    not published_at.nil?
  end
  
  def pending?
    published? and Time.now.utc < published_at
  end

  def status
    return :unpublished unless published?
    return :pending     if     pending?
    :published
  end

  def has_section?(section)
    (new_record? and section.name == 'home') or sections.include? section
  end

  def section_ids=(new_sections)
    assigned_sections.each do |assigned_section|
      new_sections.include?(assigned_section.section_id.to_s) ?
        new_sections.delete(new_sections.index(assigned_section.section_id.to_s)) :
        assigned_section.destroy
    end
    @sections_to_save = Section.find(:all, :conditions => ['id in (?)', new_sections]) unless new_sections.blank?
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

  def save_assigned_sections
    @sections_to_save.each { |section| assigned_sections.create :section => section } if @sections_to_save
  end

  def body_for_mode(mode = :list)
    (mode == :single ? excerpt_html.to_s + "\n\n" + body_html.to_s : (excerpt_html || body_html)).strip
  end
end