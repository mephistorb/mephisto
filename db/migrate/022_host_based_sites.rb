MODELS = [Content, Section, Article::Draft, Article::Version, Attachment]

class HostBasedSites < ActiveRecord::Migration
  @@models = MODELS.inject({}) { |hash, model| hash.merge model => model.table_name.to_sym }
  cattr_accessor :models
  
  def self.up
    Site.transaction do
      add_column :sites, :host, :string
    
      models.each do |model, table|
        add_column table, :site_id, :integer
        model.update_all "site_id = #{Site.find(:first).id}"
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
