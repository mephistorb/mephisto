class RemoveSiteSearchLayout < ActiveRecord::Migration
  def self.up
    remove_column "sites", "search_layout"
  end

  def self.down
    add_column "sites", "search_layout",      :string
  end
end
