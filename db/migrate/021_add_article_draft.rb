class AddArticleDraft < ActiveRecord::Migration
  def self.up
    Article.create_draft_table
  end

  def self.down
    Article.drop_draft_table
  end
end
