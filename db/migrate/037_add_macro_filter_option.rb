class AddMacroFilterOption < ActiveRecord::Migration
  User = Class.new(ActiveRecord::Base)
  def self.up
    add_column "users", "parse_macros", :boolean
    add_column "contents", "parse_macros", :boolean
    add_column "content_versions", "parse_macros", :boolean
    User.update_all ['parse_macros = ?', true]
  end

  def self.down
    remove_column "users", "parse_macros"
    remove_column "contents", "parse_macros"
    remove_column "content_versions", "parse_macros"
  end
end
