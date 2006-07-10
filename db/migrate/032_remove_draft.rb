class RemoveDraft < ActiveRecord::Migration
  def self.up
    drop_table "content_drafts"
  end

  def self.down
    create_table "content_drafts", :force => true do |t|
      t.column "article_id", :integer
      t.column "updated_at", :datetime
      t.column "title",      :string
      t.column "body",       :text
      t.column "excerpt",    :text
      t.column "site_id",    :integer
    end
  end
end
