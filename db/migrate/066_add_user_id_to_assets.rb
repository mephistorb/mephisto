class AddUserIdToAssets < ActiveRecord::Migration
  def self.up
    add_column "assets", "user_id", :integer
  end

  def self.down
    remove_column "assets", "user_id"
  end
end
