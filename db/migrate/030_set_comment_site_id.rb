class SetCommentSiteId < ActiveRecord::Migration
  class Content < ActiveRecord::Base; end
  class Article < Content; end
  class Comment < Content; end

  def self.up
    comments = Comment.find(:all, :select => 'id, site_id, article_id')
    return unless comments.any?
    articles = Article.find(:all, :select => 'id, site_id', :conditions => ['id in (?)', comments.collect(&:article_id).uniq]).inject({}) { |h, article| h.merge article.id => article }
    comments.each do |comment|
      comment.update_attribute :site_id, articles[comment.article_id].site_id
    end
  end

  def self.down
  end
end
