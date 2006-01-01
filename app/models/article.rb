class Article < ActiveRecord::Base
  has_many :taggings
  has_many :tags, :through => :taggings

  class << self
    def find_by_permalink(year, month, day, permalink)
      from, to = Time.delta(year, month, day)
      find :first, :conditions => ["permalink = ? AND articles.published_at BETWEEN ? AND ?", permalink, from, to]
    end
  end

  def to_liquid
    attributes.merge(
      'url' => full_permalink
    )
  end

  def full_permalink
    ['', published_at.year, published_at.month, published_at.day, permalink].join('/')
  end

  protected
  validates_presence_of :title
  after_validation_on_create :create_permalink
  def create_permalink
    self.permalink = title.to_permalink
  end
end
