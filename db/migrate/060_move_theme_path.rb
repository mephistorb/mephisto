class MoveThemePath < ActiveRecord::Migration
  def self.up
    base_path = Pathname.new(File.join(RAILS_ROOT, 'themes'))
    Site.find(:all).each do |site|
      site_path = base_path + "site-#{site.id}"
      new_path  = site_path + 'current'
      FileUtils.mkdir_p(new_path)
      %w(templates layouts javascripts stylesheets images).each do |dir|
        source = site_path + dir
        FileUtils.mv(source, new_path + dir) if source.exist?
      end
    end
  end

  def self.down
    base_path = Pathname.new(File.join(RAILS_ROOT, 'themes'))
    Site.find(:all).each do |site|
      site_path = base_path + "site-#{site.id}"
      new_path  = site_path + 'current'
      %w(templates layouts javascripts stylesheets images).each do |dir|
        source = new_path + dir
        FileUtils.mv(source, site_path + dir) if source.exist?
      end
      FileUtils.rmdir new_path
    end
  end
end
