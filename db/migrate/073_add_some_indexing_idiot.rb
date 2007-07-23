class AddSomeIndexingIdiot < ActiveRecord::Migration
  def self.up
    return if indexes(:assigned_sections).any? { |idx| idx.name == 'idx_a_sections_article_section' }
    add_index :assigned_sections, [:article_id, :section_id], :name => :idx_a_sections_article_section
    add_index :contents, :published_at, :name => :idx_articles_published
    add_index :contents, [:article_id, :approved, :type], :name => :idx_comments
  end

  def self.down
    remove_index :assigned_sections, :name => :idx_a_sections_article_section
    remove_index :contents, :name => :idx_articles_published
    remove_index :contents, :name => :idx_comments
  end
end
