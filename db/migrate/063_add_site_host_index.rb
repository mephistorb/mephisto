class AddSiteHostIndex < ActiveRecord::Migration
  def self.up
    add_index :sites, :host
  end

  def self.down
    remove_index :sites, :host
  end
end
