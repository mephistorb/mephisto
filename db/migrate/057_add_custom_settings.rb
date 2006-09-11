class AddCustomSettings < ActiveRecord::Migration
  class Section < ActiveRecord::Base; end
  class Site    < ActiveRecord::Base; end

  def self.up
    add_column "sites", "permalink_style", :string
    add_column "sites", "search_path", :string
    add_column "sites", "tag_path", :string
    add_column "sites", "search_template", :string
    add_column "sites", "tag_template", :string
    add_column "sections", "archive_path", :string
    add_column "sections", "archive_template", :string
    
    Site.update_all ['permalink_style = ?, search_path = ?, tag_path = ?', ':year/:month/:day/:permalink', 'search', 'tags']
    Section.update_all ['archive_path = ?', 'archives']
  end

  def self.down
    remove_column "sites", "permalink_style"
    remove_column "sites", "search_path"
    remove_column "sites", "tag_path"
    remove_column "sites", "search_template"
    remove_column "sites", "tag_template"
    remove_column "sections", "archive_path"
    remove_column "sections", "archive_template"
  end
end
