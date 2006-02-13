class OldArticle < ActiveRecord::Base
  set_table_name 'articles'
end

class RenameArticlesToContent < ActiveRecord::Migration
  def self.up
    OldArticle.transaction do
      OldArticle.find(:all, :conditions => ['type != ?', 'Comment']).each do |article|
        article[:type] = 'Article' and article.save!
      end
    end
    rename_table :articles, :contents
  end

  def self.down
    rename_table :contents, :articles
  end
end
