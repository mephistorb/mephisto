class AddSpamEngineOptionsToSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :spam_engine_options, :text
  end

  def self.down
    remove_column :sites, :spam_engine_options
  end
end
