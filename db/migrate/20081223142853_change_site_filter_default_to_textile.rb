class ChangeSiteFilterDefaultToTextile < ActiveRecord::Migration
  def self.up
    change_column :sites, :filter, :string, :default => 'textile_filter'
  end

  def self.down
    change_column :sites, :filter, :string, :default => nil
  end
end
