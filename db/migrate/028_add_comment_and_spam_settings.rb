class AddCommentAndSpamSettings < ActiveRecord::Migration
  def self.up
    add_column "sites", "comment_lifetime", :integer
    add_column "sites", "comment_link_max", :integer
    add_column "sites", "akismet_key", :string, :limit => 100
    add_column "sites", "akismet_url", :string
  end

  def self.down
    remove_column "sites", "comment_lifetime"
    remove_column "sites", "comment_link_max"
    remove_column "sites", "akismet_key"
    remove_column "sites", "akismet_url"
  end
end
