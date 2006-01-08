class AddCachedPage < ActiveRecord::Migration
  def self.up
    create_table :cached_pages, :force => true do |t|
      t.column :url,        :string, :limit => 255
      t.column :references, :text
      t.column :updated_at, :datetime
    end

    drop_table :cached_references rescue nil
  end

  def self.down
    drop_table :cached_references
    drop_table :cached_pages
  end
end
