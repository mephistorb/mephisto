class AddEventAuthor < ActiveRecord::Migration
  def self.up
    # yes this time i'm sure, i *really* want this field
    add_column "events", "author", :string, :limit => 100
  end

  def self.down
    remove_column "events", "author"
  end
end
