class AddSpamEngineDataToContents < ActiveRecord::Migration
  def self.up
    add_column :contents, :spam_engine_data, :text
  end

  def self.down
    remove_column :contents, :spam_engine_data
  end
end
