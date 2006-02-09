class RenameTagsToCategories < ActiveRecord::Migration
  def self.up
    rename_column :taggings, :tag_id, :category_id
    rename_table  :tags, :categories
    rename_table  :taggings, :categorizations
  end

  def self.down
    rename_table  :categories, :tags
    rename_table  :categorizations, :taggings
    rename_column :taggings, :category_id, :tag_id
  end
end
