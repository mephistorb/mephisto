class AddCorrectCommentLifetime < ActiveRecord::Migration
  class Site < ActiveRecord::Base ; end
  class Content < ActiveRecord::Base ; end
  class Article < Content ; end

  def self.up
    remove_column "sites", "comment_lifetime"
    remove_column "sites", "comment_link_max"
    add_column "sites", "accept_comments", :boolean
    add_column "sites", "approve_comments", :boolean
    add_column "sites", "comment_age", :integer
    add_column "contents", "expire_comments_at", :datetime
    add_column "content_versions", "expire_comments_at", :datetime
    Site.find(:all, :select => 'id, accept_comments, approve_comments, comment_age').each do |site|
      site.update_attributes(:accept_comments => true, :approve_comments => false, :comment_age => 30)
    end
    Article.find(:all, :select => 'id, created_at, expire_comments_at').each do |article|
      article.update_attribute(:expire_comments_at, (article.created_at + 30.days))
    end
  end

  def self.down
    add_column "sites", "comment_lifetime", :integer
    add_column "sites", "comment_link_max", :integer
    remove_column "sites", "accept_comments"
    remove_column "sites", "approve_comments"
    remove_column "sites", "comment_age"
    remove_column "contents", "expire_comments_at"
    remove_column "content_versions", "expire_comments_at"
  end
end
