class StoreSingleFilter < ActiveRecord::Migration
  class User < ActiveRecord::Base
    serialize :filters, Array
  end
  class Site < ActiveRecord::Base
    serialize :filters, Array
  end
  class Content < ActiveRecord::Base
    serialize :filters, Array
  end
  class ContentVersion < ActiveRecord::Base
    serialize :filters, Array
  end
  FILTERED_MODELS = [User, Site, Content, ContentVersion]
  def self.up
    FILTERED_MODELS.each do |klass|
      add_column klass.table_name, "filter", :string
    end
    User.transaction do
      FILTERED_MODELS.each do |klass|
        say_with_time "Converted #{klass.name}#filters to #filter" do
          klass.find(:all, :select => 'id, filters, filter').each do |record|
            record.filter = record.filters.blank? ? nil : record.filters.reject { |f| f.blank? }.first.to_s
            record.save!
          end
        end
      end
    end
    
    FILTERED_MODELS.each do |klass|
      remove_column klass.table_name, "filters"
    end
  rescue
    down
    raise
  end

  def self.down
    FILTERED_MODELS.each do |klass|
      remove_column klass.table_name, "filter"
      add_column klass.table_name, "filters", :text
    end
  end
end
