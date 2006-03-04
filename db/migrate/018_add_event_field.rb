class AddEventField < ActiveRecord::Migration
  def self.up
    add_column "events", "author", :string, :limit => 100
    add_column "events", "author_url", :string
    add_column "events", "author_email", :string
    add_column "events", "author_ip", :string, :limit => 100
  end

  def self.down
    remove_column "events", "author"
    remove_column "events", "author_url"
    remove_column "events", "author_email"
    remove_column "events", "author_ip"
  end
end
