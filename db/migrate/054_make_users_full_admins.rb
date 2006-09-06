class MakeUsersFullAdmins < ActiveRecord::Migration
  class User < ActiveRecord::Base; end
  def self.up
    User.update_all ['admin = ?', true]
  end

  def self.down
  end
end
