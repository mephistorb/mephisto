class Tag < ActiveRecord::Base
  has_many :taggings, :dependent => :delete_all
  has_many :articles, :order => 'taggings.position', :through => :taggings do
    def find_by_date(options = {})
      find(:all, { :order => 'articles.published_at desc', 
                   :conditions => ['published_at <= ? AND articles.type IS NULL AND articles.published_at IS NOT NULL', Time.now.utc] } \
        .merge(options))
    end

    def find_by_position(options = {})
      find(:first, { :order => 'taggings.position',
                   :conditions => ['published_at <= ? AND articles.type IS NULL AND articles.published_at IS NOT NULL', Time.now.utc] } \
        .merge(options))
    end

    def find_by_permalink(permalink, options = {})
      find(:first, { :order => 'taggings.position',
                   :conditions => ['articles.permalink = ? AND published_at <= ? AND articles.type IS NULL AND articles.published_at IS NOT NULL',
                                   permalink, Time.now.utc] }.merge(options))
    end
  end

  class << self
    def find_paged(options = {})
      with_scope :find => { :conditions => ['show_paged_articles = ?', true] } do
        block_given? ? yield : find(:all, options)
      end
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
