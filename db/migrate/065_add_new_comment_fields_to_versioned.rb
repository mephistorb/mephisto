class AddNewCommentFieldsToVersioned < ActiveRecord::Migration
  def self.up
    add_column "content_versions", "user_agent", :string
    add_column "content_versions", "referrer", :string
  end

  def self.down
    remove_column "content_versions", "user_agent"
    remove_column "content_versions", "referrer"
  end
end
