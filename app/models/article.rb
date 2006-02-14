class Article < Content
  validates_presence_of :title, :user_id

  before_create :create_permalink
  after_save    :save_categorizations

  has_many :categorizations
  has_many :categories, :through => :categorizations, :order => 'categories.name'
  has_many :comments,   :order => 'created_at'
  
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

  def has_category?(category)
    (new_record? and category.name == 'home') or categories.include? category
  end

  def category_ids=(new_categories)
    categorizations.each do |categorization|
      new_categories.include?(categorization.category_id.to_s) ?
        new_categories.delete(new_categories.index(categorization.category_id.to_s)) :
        categorization.destroy
    end
    @categories_to_save = Category.find(:all, :conditions => ['id in (?)', new_categories]) unless new_categories.blank?
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

  def save_categorizations
    @categories_to_save.each { |category| categorizations.create :category => category } if @categories_to_save
  end

  def body_for_mode(mode = :list)
    (mode == :single ? excerpt_html.to_s + "\n\n" + body_html.to_s : (excerpt_html || body_html)).strip
  end
end