SITE_DIR = File.join(RAILS_ROOT, 'themes/site-' + (ENV['SITE_ID'] || '1'))
namespace :db do
  desc "Loads a schema.rb file into the database and then loads the initial database fixtures."
  task :bootstrap do
    mkdir_p File.join(RAILS_ROOT, 'log')
    
    require 'rubygems' unless Object.const_defined?(:Gem)
    begin
      require 'tzinfo'
    rescue LoadError
      puts
      puts '=' * 80
      puts
      puts "You are missing the tzinfo gem.  Please install it before proceeding."
      puts
      puts "If you can't install on your server:"
      puts "  gem install tzinfo (from your local machine)"
      puts "  rake gems:freeze GEM=tzinfo (from the mephisto directory)"
      puts
      puts "Now, upload the vendor/tzinfo-0.3.1 folder with the rest of Mephisto.'"
      puts
      puts '=' * 80
      puts
      raise
    end
    
    %w(environment db:schema:load db:bootstrap:load tmp:create).each { |t| Rake::Task[t].execute }
    if File.exists?(SITE_DIR)
      puts "skipping default theme creation..."
    else
      Rake::Task["db:bootstrap:copy_default_theme"].execute
      puts "copied default theme to #{SITE_DIR}..."
    end
    
    puts
    puts '=' * 80
    puts
    puts "Thank you for trying out Mephisto #{Mephisto::Version::STRING}: #{Mephisto::Version::TITLE} Edition!"
    puts
    puts "Now you can start the application with script/server, visit "
    puts "http://mydomain.com/admin, and log in with admin / test."
    puts
    puts "For help, visit the following:"
    puts "  Official Mephisto Site - http://mephistoblog.com"
    puts "  The Mephisto Community Wiki - http://mephisto.stikipad.com/"
    puts "  The Mephisto Google Group - http://groups.google.com/group/MephistoBlog"
    puts
  end
  
  namespace :bootstrap do
    desc "Load initial database fixtures (in db/bootstrap/*.yml) into the current environment's database.  Load specific fixtures using FIXTURES=x,y"
    task :load => :environment do
      require 'active_record/fixtures'
      ActiveRecord::Base.establish_connection(RAILS_ENV.to_sym)
      (ENV['FIXTURES'] ? ENV['FIXTURES'].split(/,/) : Dir.glob(File.join(RAILS_ROOT, 'db', 'bootstrap', '*.{yml,csv}'))).each do |fixture_file|
        Fixtures.create_fixtures('db/bootstrap', File.basename(fixture_file, '.*'))
      end
    end
    
    desc "Copy default theme to site theme"
    task :copy_default_theme do
      FileUtils.mkdir_p SITE_DIR
      FileUtils.cp_r File.join(RAILS_ROOT, 'themes/default'), File.join(SITE_DIR, 'current')
      Dir[File.join(RAILS_ROOT, 'themes/site-1/current/**/.svn')].each do |dir|
        FileUtils.rm_rf dir
      end
    end
  end
end