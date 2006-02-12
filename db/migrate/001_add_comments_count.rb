class TempArticle < ActiveRecord::Base
  set_table_name 'articles'
end

class AddCommentsCount < ActiveRecord::Migration
  def self.up
    change_column :articles, :comments_count, :integer, :default => 0
    TempArticle.find_all_by_article_id(nil).each { |a| a.save }
  end

  def self.down
  end
end
