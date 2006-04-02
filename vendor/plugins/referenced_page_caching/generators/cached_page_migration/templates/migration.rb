class <%= class_name %> < ActiveRecord::Migration
  def self.up
    create_table :cached_pages, :force => true do |t|
      t.column :url,        :string, :limit => 255
      t.column :references, :text
      t.column :updated_at, :datetime
    end

    # old, unused table in previous referenced_page_caching version
    drop_table :cached_references rescue nil
  end

  def self.down
    drop_table :cached_references
    drop_table :cached_pages
  end
end
