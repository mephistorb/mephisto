class AddTagType < ActiveRecord::Migration
  def self.up
    add_column :tags, :show_paged_articles, :boolean, :default => false
  end

  def self.down
    remove_column :tags, :show_paged_articles
  end
end
