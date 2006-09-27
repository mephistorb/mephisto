class AddSectionPosition < ActiveRecord::Migration
  def self.up
    add_column "sections", "position", :integer, :default => 1
  end

  def self.down
    remove_column "sections", "position"
  end
end
