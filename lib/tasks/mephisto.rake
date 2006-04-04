desc "Initialize Mephisto with optional HOST=your.com"
task :install_mephisto => [:db_schema_import, :create_site]

desc "Create a new site with HOST=your.com"
task :create_site => :environment do
  Site.transaction do
    site = Site.new  :host => ENV['HOST'], :title => ENV['TITLE'] || 'Mephisto'
    site.save!
    
    site.sections.build(:name => 'home').save!
    Dir[File.join(RAILS_ROOT, 'app', 'themes', 'default', '*.liquid')].each do |file|
      site.templates.build(:filename => File.basename(file).split('.').first, :data => IO.read(file)).save!
    end
  end
end