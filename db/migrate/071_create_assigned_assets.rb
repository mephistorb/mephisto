class CreateAssignedAssets < ActiveRecord::Migration
  def self.up
    create_table :assigned_assets do |t|
      t.column :article_id, :integer
      t.column :asset_id, :integer
      t.column :position, :integer
      t.column :label, :string
      t.column :created_at, :datetime
      t.column :active, :boolean
    end
    add_column "contents", "assets_count", :integer, :default => 0
    add_column "content_versions", "assets_count", :integer, :default => 0
  end

  def self.down
    drop_table :assigned_assets
    remove_column "contents", "assets_count"
    remove_column "content_versions", "assets_count"
  end
end
