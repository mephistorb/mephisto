class AddCommentModeration < ActiveRecord::Migration
  def self.up
    add_column "contents", "approved", :boolean, :default => false
    add_column "content_versions", "approved", :boolean, :default => false
  end

  def self.down
    remove_column "contents", "approved"
    remove_column "content_versions", "approved"
  end
end
