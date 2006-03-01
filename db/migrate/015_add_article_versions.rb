class AddArticleVersions < ActiveRecord::Migration
  class Content < ActiveRecord::Base
    acts_as_versioned
  end

  def self.up
    add_column :contents, :updater_id, :integer
    Content.create_versioned_table
  end

  def self.down
    remove_column :contents, :updater_id
    Content.drop_versioned_table
  end
end
