class AddSectionAttributes < ActiveRecord::Migration
  class Template < ActiveRecord::Base
    set_table_name 'attachments'
  end
  
  def self.up
    add_column :sections, :articles_per_page, :integer, :default => 15
    add_column :sections, :layout,            :string
    add_column :sections, :template,          :string

    Section.transaction do
      Section.find(:all).each do |section|
        section.articles_per_page = 15
        section.save!
      end
    end
    
    Template.transaction do
      Template.find(:all).each do |template|
        if template.filename == 'layout'
          template[:type] = 'LayoutTemplate'
          template.save!
        end
      end
    end
  end

  def self.down
    remove_column :sections, :articles_per_page
    remove_column :sections, :layout
    remove_column :sections, :template
  end
end
