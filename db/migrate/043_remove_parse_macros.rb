class RemoveParseMacros < ActiveRecord::Migration
  def self.up
    %w(users contents content_versions).each { |t| remove_column t, :parse_macros }
  end

  def self.down
    %w(users contents content_versions).each { |t| add_column t, :parse_macros, :boolean }
  end
end
