class Tag < ActiveRecord::Base
  has_many :taggings
  has_many :articles, :through => :taggings, 
    :conditions => 'articles.published_at IS NOT NULL', 
    :order      => 'articles.published_at DESC'

  protected
  validates_presence_of :title
end
