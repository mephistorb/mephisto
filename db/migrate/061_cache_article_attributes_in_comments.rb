class CacheArticleAttributesInComments < ActiveRecord::Migration
  class Content < ActiveRecord::Base; end
  class Article < Content; end
  class Comment < Content; end

  def self.up
    Comment.transaction do
      Article.find(:all, :select => 'id, title, published_at, permalink').each do |article|
        Comment.update_all ['title = ?, published_at = ?, permalink = ?', article.title, article.published_at, article.permalink], ['article_id = ?', article.id]
      end
    end
  end

  def self.down
  end
end
