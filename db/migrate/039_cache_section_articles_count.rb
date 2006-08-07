class CacheSectionArticlesCount < ActiveRecord::Migration
  class AssignedSection < ActiveRecord::Base
    belongs_to :section
  end
  class Section < ActiveRecord::Base; end
  def self.up
    add_column "sections", "articles_count", :integer, :default => 0
    say_with_time "Update Section articles_count values..." do
      AssignedSection.count(:all, :group => :section_id).each do |section_id, count|
        Section.update_all ['articles_count = ?', count], ['id = ?', section_id]
      end
    end
  end

  def self.down
    remove_column "sections", "articles_count"
  end
end
