class AddEvents < ActiveRecord::Migration
  def self.up
    create_table "events" do |t|
      t.column "mode", :string
      t.column "user_id", :integer
      t.column "article_id", :integer
      t.column "title", :text
      t.column "body", :text
      t.column "created_at", :datetime
    end
  end

  def self.down
    drop_table "events"
  end
end
