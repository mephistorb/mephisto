class UserHostileTemplateMigration < ActiveRecord::Migration
  class Site < ActiveRecord::Base
    has_many :attachments
  end
  class DbFile < ActiveRecord::Base; end
  class Attachment < ActiveRecord::Base
    belongs_to :site
    has_attachment
  end
  class Avatar   < Attachment; end
  class Asset    < Attachment; end
  class Template < Attachment; end
  class Resource < Attachment; end

  def self.up
    Site.find(:all).each do |site|
      path = File.join(RAILS_ROOT, 'themes', "site-#{site.id}")
      say_with_time "Saved site theme to #{path}..." do
        site.attachments.find(:all, :conditions => ['attachments.type in (?)', %w(Resource Template)]).each do |att|
          %w(templates layouts javascripts stylesheets images).each { |d| FileUtils.mkdir_p File.join(path, d) }
          filename = case att
            when Resource then File.join(att.path, att.filename)
            when Template then File.join(att.filename =~ /layout/ ? 'layouts' : 'templates', att.filename + '.liquid')
          end
          say "Wrote #{filename}..."
          File.open(File.join(path, filename), 'w') { |f| f.write att.db_file.data }
        end
      end
    end
    drop_table :db_files
    remove_column :attachments, :path
    Attachment.delete_all ['type in (?)', %w(Asset Avatar)]
  end

  def self.down
    puts 'hah, yea right!'
  end
end