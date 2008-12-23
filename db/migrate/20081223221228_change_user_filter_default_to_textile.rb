class ChangeUserFilterDefaultToTextile < ActiveRecord::Migration
  def self.up
    change_column :users, :filter, :string, :default => 'textile_filter'
  end

  def self.down
    change_column :users, :filter, :string, :default => nil
  end
end
