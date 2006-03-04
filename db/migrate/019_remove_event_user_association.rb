class RemoveEventUserAssociation < ActiveRecord::Migration
  def self.up
    remove_column "events", "author"
    remove_column "events", "author_url"
    remove_column "events", "author_email"
    remove_column "events", "author_ip"
  end

  def self.down
    add_column "events", "author", :string, :limit => 100
    add_column "events", "author_url", :string
    add_column "events", "author_email", :string
    add_column "events", "author_ip", :string, :limit => 100
  end
end
