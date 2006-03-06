class AddArticleDraft < ActiveRecord::Migration
  class Article < ::Content
    acts_as_draftable :fields => [:title, :body, :excerpt]
  end
  
  def self.up
    Article.create_drafted_table
  end

  def self.down
    Article.drop_drafted_table
  end
end
