class AddSettings < ActiveRecord::Migration
  def self.up
    create_table :sites do |t|
      t.column :title,     :string, :limit => 255
      t.column :subtitle,  :string, :limit => 255
      t.column :email,     :string, :limit => 255
      t.column :ping_urls, :text
      t.column :filters,   :text
      t.column :articles_per_page, :integer, :default => 15
    end
    
    add_column :articles, :filters, :text
    add_column :users,    :filters, :text
    
    Site.create :title => 'Mephisto'
  end

  def self.down
    drop_table :sites
    
    remove_column :articles, :filters
    remove_column :users, :filters
  end
end
