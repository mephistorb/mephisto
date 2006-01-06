class Article < ActiveRecord::Base
  belongs_to :user
  has_many   :taggings
  has_many   :tags, :through => :taggings
  has_many   :comments
  
  validates_presence_of :title, :user_id

  after_validation_on_create :create_permalink
  before_save :cache_redcloth
  after_save  :save_taggings

  class << self
    def find_by_permalink(year, month, day, permalink)
      from, to = Time.delta(year, month, day)
      find :first, :conditions => ["published_at <= ? AND type IS NULL AND permalink = ? AND published_at BETWEEN ? AND ?", 
        Time.now.utc, permalink, from, to]
    end
    
    def find_all_by_published_date(year, month, day = nil)
      from, to = Time.delta(year, month, day)
      find :all, :order => 'published_at DESC', :conditions => ["published_at <= ? AND type IS NULL AND published_at BETWEEN ? AND ?", 
        Time.now.utc, from, to]
    end
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

  def tag_ids=(new_tags)
    taggings.each do |tagging|
      new_tags.include?(tagging.tag_id.to_s) ?
        new_tags.delete(new_tags.index(tagging.tag_id.to_s)) :
        tagging.destroy
    end
    @tags_to_save = Tag.find(:all, :conditions => ['id in (?)', new_tags])
  end

  def to_liquid(mode = :list)
    mode = :list unless mode == :single
    { 'title'          => title,
      'permalink'      => permalink,
      'url'            => full_permalink,
      'body'           => (mode == :list ? (summary_html || description_html) : description_html),
      'published_at'   => published_at,
      'comments_count' => comments_count }
  end

  def hash_for_permalink
    { :year      => published_at.year, 
      :month     => published_at.month, 
      :day       => published_at.day, 
      :permalink => permalink }
  end

  def full_permalink
    ['', published_at.year, published_at.month, published_at.day, permalink].join('/')
  end

  protected
  def create_permalink
    self.permalink = title.to_permalink
  end

  def cache_redcloth
    self.summary_html     = RedCloth.new(summary).to_html     unless summary.blank?
    self.description_html = RedCloth.new(description).to_html unless description.blank?
  end

  def save_taggings
    @tags_to_save.each { |tag| taggings.create :tag => tag } if @tags_to_save
  end
end
