task :install_mephisto => :db_schema_import do
  Category.create :name => 'home'
  Site.create :title => 'Mephisto'
  Dir[File.join(RAILS_ROOT, 'app', 'themes', 'default', '*.liquid')].each do |file|
    Template.create(:name => File.basename(file).split('.').first, :data => IO.read(file))
  end
end