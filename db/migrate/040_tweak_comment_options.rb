class TweakCommentOptions < ActiveRecord::Migration
  class Content < ActiveRecord::Base; end
  def self.up
    remove_column :sites, :accept_comments
    remove_column :contents, :expire_comments_at
    remove_column :content_versions, :expire_comments_at
    add_column "contents", "comment_age", :integer, :default => 0
    add_column "content_versions", "comment_age", :integer, :default => 0
    Content.update_all 'comment_age=30'
  end

  def self.down
    add_column "sites", "accept_comments", :boolean
    add_column "contents", "expire_comments_at", :datetime
    add_column "content_versions", "expire_comments_at", :datetime
    remove_column "contents", "comment_age"
    remove_column "content_versions", "comment_age"
  end
end
