class AddLangToSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :lang, :string, :null => false, :default => 'en-US'
  end

  def self.down
    remove_column :sites, :lang
  end
end
