class HostBasedSites < ActiveRecord::Migration
  class Content < ActiveRecord::Base; end
  class Section < ActiveRecord::Base; end
  class ContentDraft < ActiveRecord::Base; end
  class ContentVersion < ActiveRecord::Base; end
  class Attachment < ActiveRecord::Base; end
  
  @@models = [Content, Section, ContentDraft, ContentVersion, Attachment].inject({}) { |hash, model| hash.merge model => model.table_name.to_sym }
  cattr_accessor :models
  
  def self.up
    Site.transaction do
      add_column :sites, :host, :string
      site = Site.find(:first).id
    
      models.each do |model, table|
        add_column table, :site_id, :integer
        model.update_all "site_id = #{site.id}"
      end
    end
  end

  def self.down
    Site.transaction do
      remove_column :sites, :host
      models.each { |model, table| remove_column table, :site_id }
    end
  end
end
