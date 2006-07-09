class SetCommentSiteId < ActiveRecord::Migration
  class Content < ActiveRecord::Base; end
  class Article < Content; end
  class Comment < Content; end

  def self.up
    comments = Comment.find(:all, :select => 'id, site_id, article_id')
    return unless comments.any?
    articles = Article.find(:all, :select => 'id, site_id', :conditions => ['id in (?)', comments.collect(&:article_id).uniq]).inject({}) { |h, article| h.merge article.id.to_s => article }
    comments.each do |comment|
      article = articles[comment.article_id.to_s]
      if article
        comment.update_attribute :site_id, article.site_id
      else
        say "Comment ##{comment.id} has an invalid article ##{comment.article_id}"
      end
    end
  end

  def self.down
  end
end
