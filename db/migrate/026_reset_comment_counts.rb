class ResetCommentCounts < ActiveRecord::Migration
  class Content < ActiveRecord::Base
  end
  class Article < Content
  end
  class Comment < Content
    belongs_to :article
  end

  def self.up
    Comment.count(:all, :group => :article, :conditions => ['approved = ?', true]).each do |article, count|
      article.update_attributes :comments_count => count
    end
  end

  def self.down
    # JDM
  end
end
