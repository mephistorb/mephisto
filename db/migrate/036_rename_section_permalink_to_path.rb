class RenameSectionPermalinkToPath < ActiveRecord::Migration
  class Section < ActiveRecord::Base; end
  def self.up
    rename_column :sections, :permalink, :path
    Section.find(:all, :select => 'id, name, path').each do |section|
      section.path = section.name.to_s.gsub(/[^\w\/]|[!\(\)\.]+/, ' ').strip.downcase.gsub(/\ +/, '-') if section.path.blank?
      section.save
    end
  end

  def self.down
    rename_column :sections, :path, :permalink
  end
end
