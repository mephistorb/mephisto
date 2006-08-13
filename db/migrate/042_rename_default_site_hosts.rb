class RenameDefaultSiteHosts < ActiveRecord::Migration
  class Site < ActiveRecord::Base; end
  def self.up
    Site.update_all "host = 'unusedfornow.com'", "host = 'unusedfornow'"
  end

  def self.down
  end
end
