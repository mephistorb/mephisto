class SetDefaultFilters < ActiveRecord::Migration
  class Content < ActiveRecord::Base
    belongs_to :user
  end
  class Article < Content ; end
  class User    < ActiveRecord::Base ; end
  
  def self.up
    Article.transaction do
      User.find(:all, :conditions => ['filters IS NULL']).each do |user|
        user.filters = [:textile_filter]
        user.save!
      end
      
      Article.find(:all, :conditions => ['contents.filters IS NULL'], :include => :user).each do |article|
        article.filters = article.user.filters
        article.save!
      end
    end
  end

  def self.down
    # well, whatever nevermind
  end
end
