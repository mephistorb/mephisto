class AddCommentsCount < ActiveRecord::Migration
  def self.up
    change_column :articles, :comments_count, :integer, :default => 0
    Article.find_all_by_article_id(nil).each { |a| a.save }
  end

  def self.down
  end
end
