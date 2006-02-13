task :install_mephisto => :db_schema_import do
  Category.transaction do
    Category.new(:name => 'home').save!
    Site.new(:title => 'Mephisto').save!
    Dir[File.join(RAILS_ROOT, 'app', 'themes', 'default', '*.liquid')].each do |file|
      Template.new(:filename => File.basename(file).split('.').first, :data => IO.read(file)).save!
    end
  end
end