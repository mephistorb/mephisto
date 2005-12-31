class Article < ActiveRecord::Base
  has_many :taggings
  has_many :tags, :through => :taggings

  def to_liquid
    attributes
  end

  protected
  validates_presence_of :title
  after_validation_on_create :create_permalink
  def create_permalink
    self.permalink = title.to_permalink
  end
end
