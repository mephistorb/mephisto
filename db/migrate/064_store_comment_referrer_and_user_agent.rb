class StoreCommentReferrerAndUserAgent < ActiveRecord::Migration
  def self.up
    add_column "contents", "user_agent", :string
    add_column "contents", "referrer", :string
  end

  def self.down
    remove_column "contents", "user_agent"
    remove_column "contents", "referrer"
  end
end
