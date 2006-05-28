class AddCommentModeration < ActiveRecord::Migration
  class Content < ActiveRecord::Base
  end
  class Comment < Content
  end
  def self.up
    add_column "contents", "approved", :boolean, :default => false
    add_column "content_versions", "approved", :boolean, :default => false
    Comment.update_all ['approved=?', true]
  end

  def self.down
    remove_column "contents", "approved"
    remove_column "content_versions", "approved"
  end
end
