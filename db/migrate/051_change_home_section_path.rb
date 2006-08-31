class ChangeHomeSectionPath < ActiveRecord::Migration
  def self.up
    execute "update sections set path = '' where path = 'home'"
  end

  def self.down
    execute "update sections set path = 'home' where path = ''"
  end
end