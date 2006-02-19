class OldAttachment < ActiveRecord::Base
  set_table_name 'attachments'
end

class RenameCategoriesToSections < ActiveRecord::Migration
  def self.up
    rename_column :categorizations, :category_id, :section_id
    rename_table  :categories, :sections
    rename_table  :categorizations, :assigned_sections
    OldAttachment.transaction do
      OldAttachment.find(:all, :conditions => ['filename = ?', 'category']).each { |t| t.name = 'section'; t.save! }
    end
  end

  def self.down
    rename_table  :categories, :categories
    rename_table  :categorizations, :categorizations
    rename_column :categorizations, :category_id, :category_id
    OldAttachment.transaction do
      OldAttachment.find(:all, :conditions => ['filename = ?', 'section']).each { |t| t.name = 'category'; t.save! }
    end
  end
end
