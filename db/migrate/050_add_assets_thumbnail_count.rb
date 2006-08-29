class AddAssetsThumbnailCount < ActiveRecord::Migration
  class Asset < ActiveRecord::Base ; end
  def self.up
    add_column "assets", "thumbnails_count", :integer, :default => 0
    assets = Asset.find(:all, :select => 'id, thumbnails_count', :conditions => 'parent_id is null')
    say_with_time "Setting thumbnail counts for #{assets.size} asset(s)..." do
      assets.each do |asset|
        Asset.update_all ['thumbnails_count = ?', Asset.count(:all, :conditions => ['parent_id = ?', asset.id])], ['id = ?', asset.id]
      end
    end
  end

  def self.down
    remove_column "assets", "thumbnails_count"
  end
end
