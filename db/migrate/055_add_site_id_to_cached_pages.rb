class AddSiteIdToCachedPages < ActiveRecord::Migration
  def self.up
    add_column "cached_pages", "site_id", :integer
    add_column "cached_pages", "cleared_at", :datetime
  end

  def self.down
    remove_column "cached_pages", "site_id"
    remove_column "cached_pages", "cleared_at"
  end
end
