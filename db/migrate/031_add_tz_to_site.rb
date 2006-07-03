class AddTzToSite < ActiveRecord::Migration
  class Site < ActiveRecord::Base;end
  def self.up
    add_column :sites, :timezone, :string
    Site.find(:all, :select => 'id, timezone').each do |site|
      site.update_attribute :timezone, 'UTC' if site.timezone.blank?
    end
  end

  def self.down
    remove_column :sites, :timezone
  end
end
