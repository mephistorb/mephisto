class AddSectionPermalink < ActiveRecord::Migration
  def self.up
    add_column "sections", "permalink", :string
  end

  def self.down
    remove_column "sections", "permalink"
  end
end
