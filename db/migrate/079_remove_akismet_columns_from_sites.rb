class RemoveAkismetColumnsFromSites < ActiveRecord::Migration
  def self.up
    remove_column :sites, :akismet_url
    remove_column :sites, :akismet_key
  end

  def self.down
    add_column :sites, :akismet_key, :string, :limit => 100
    add_column :sites, :akismet_url, :string
  end
end
