class Tag < ActiveRecord::Base
  has_many :taggings, :dependent => :delete_all
  has_many :articles, :through => :taggings,
    :conditions => ['published_at <= ? AND articles.type IS NULL AND articles.published_at IS NOT NULL', Time.now.utc] do
    def find_by_date(options = {})
      find(:all, { :order => 'articles.published_at desc' }.merge(options))
    end

    def find_by_position(options = {})
      find(:all, { :order => 'taggings.position' }.merge(options))
    end
  end

  def hash_for_url(options = {})
    { :tags => to_url }.merge(options)
  end

  def to_url
    ((name.nil? or name == 'home') ? '' : name).split('/')
  end

  protected
  validates_presence_of :name
end
