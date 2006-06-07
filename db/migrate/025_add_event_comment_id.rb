class AddEventCommentId < ActiveRecord::Migration
  def self.up
    add_column "events", "comment_id", :integer
  end

  def self.down
    remove_column "events", "comment_id"
  end
end
