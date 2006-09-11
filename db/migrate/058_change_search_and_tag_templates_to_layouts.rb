class ChangeSearchAndTagTemplatesToLayouts < ActiveRecord::Migration
  def self.up
    rename_column :sites, :search_template, :search_layout
    rename_column :sites, :tag_template, :tag_layout
  end

  def self.down
    rename_column :sites, :search_layout, :search_template
    rename_column :sites, :tag_layout, :tag_template
  end
end
