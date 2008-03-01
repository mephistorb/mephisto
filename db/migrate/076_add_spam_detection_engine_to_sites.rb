class AddSpamDetectionEngineToSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :spam_detection_engine, :string
  end

  def self.down
    remove_column :sites, :spam_detection_engine
  end
end
