class ResetCommentCounts < ActiveRecord::Migration
  class Content < ActiveRecord::Base
  end
  class Article < Content
  end
  class Comment < Content
    belongs_to :article
  end

  def self.up
    Comment.count(:all, :group => :article_id, :conditions => ['approved = ?', true]).each do |article, count|
      Article.update_all ['comments_count = ?', count], ['id = ?', article]
    end
  end

  def self.down
    # JDM
  end
end
