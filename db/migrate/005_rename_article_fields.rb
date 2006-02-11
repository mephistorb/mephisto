class RenameArticleFields < ActiveRecord::Migration
  def self.up
    rename_column :articles, :description,      :body
    rename_column :articles, :description_html, :body_html
    rename_column :articles, :summary,          :excerpt
    rename_column :articles, :summary_html,     :excerpt_html
  end

  def self.down
    rename_column :articles, :body,         :description
    rename_column :articles, :body_html,    :description_html
    rename_column :articles, :excerpt,      :summary
    rename_column :articles, :excerpt_html, :summary_html
  end
end
