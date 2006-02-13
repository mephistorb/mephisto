class Category < ActiveRecord::Base
  validates_presence_of :name
  has_many :categorizations, :dependent => :delete_all
  has_many :articles, :order => 'categorizations.position', :through => :categorizations do
    def find_by_date(options = {})
      find(:all, { :order => 'contents.published_at desc', 
                   :conditions => ['published_at <= ? AND contents.published_at IS NOT NULL', Time.now.utc] } \
        .merge(options))
    end

    def find_by_position(options = {})
      find(:first, { :order => 'categorizations.position',
                   :conditions => ['published_at <= ? AND contents.published_at IS NOT NULL', Time.now.utc] } \
        .merge(options))
    end

    def find_by_permalink(permalink, options = {})
      find(:first, { :order => 'categorizations.position',
                   :conditions => ['contents.permalink = ? AND published_at <= ? AND contents.published_at IS NOT NULL',
                                   permalink, Time.now.utc] }.merge(options))
    end
  end

  class << self
    # scopes a find operation to return only paged categories
    def find_paged(options = {})
      with_scope :find => { :conditions => ['show_paged_articles = ?', true] } do
        block_given? ? yield : find(:all, options)
      end
    end
    
    # given a category name like ['about', 'site_map'], about is the category and site_map is a left over page_name
    # returns [<#Category: about>, 'site_map']
    def find_category_and_page_name(category_path)
      page_name = []
      category       = nil
      while category.nil? and category_path.any?
        category       = find_by_name(category_path.join('/'))
        page_name << category_path.pop if category.nil?
      end
      [category, page_name.any? ? page_name.join('/') : nil]
    end
  end

  def title
    name.to_s.split('/').last.humanize
  end

  def hash_for_url(options = {})
    { :categories => to_url }.merge(options)
  end

  def to_url
    ((name.nil? or name == 'home') ? '' : name).split('/')
  end
end
