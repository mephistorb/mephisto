class AddPasswordResetCode < ActiveRecord::Migration
  def self.up
    rename_column :users, :remember_token, :token
    rename_column :users, :remember_token_expires_at, :token_expires_at
  end

  def self.down
    rename_column :users, :token, :remember_token
    rename_column :users, :token_expires_at, :remember_token_expires_at
  end
end
