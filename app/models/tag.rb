class Tag < ActiveRecord::Base
  has_many :taggings, :dependent => :delete_all
  has_many :articles, :through => :taggings, :conditions => 'articles.published_at IS NOT NULL' do
    def find_by_date(options = {})
      find(:all, { :order => 'articles.published_at' }.merge(options))
    end

    def find_by_position(options = {})
      find(:all, { :order => 'taggings.position' }.merge(options))
    end
  end

  protected
  validates_presence_of :name
end
