class RemoveOrphanComments < ActiveRecord::Migration
  def self.up
    article_ids = select_values("SELECT id FROM contents WHERE type = 'Article'")
    Comment.delete_all(['article_id NOT IN (?)', article_ids])
  end

  def self.down
  end
end
