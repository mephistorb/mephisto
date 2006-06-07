class AddSiteToEvents < ActiveRecord::Migration
  class Event < ActiveRecord::Base
    belongs_to :site
  end
  class Site < ActiveRecord::Base
  end

  def self.up
    add_column "events", "site_id", :integer
    Event.update_all ['site_id = ?', Site.find(:first).id]
  end

  def self.down
    remove_column "events", "site_id"
  end
end
