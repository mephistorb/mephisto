desc "Sets up a cloudnine app on a remote server with switchtower"
task :init do
  ENV['SHARED_PATH']  = '../../shared' unless ENV['SHARED_PATH']
  ENV['RAILS_PATH'] ||= File.join(ENV['SHARED_PATH'], 'rails')
  puts 'copying files...'
  cp "#{ENV['SHARED_PATH']}/database.yml",      'config'
  cp "#{ENV['SHARED_PATH']}/lighttpd.conf",     'config' rescue nil # not all of us have this you know
  cp "#{ENV['SHARED_PATH']}/dispatch.fcgi",     'public'

  puts 'setting permissions...'
  chmod 0600, 'config/database.yml'
  chmod 0700, 'public/dispatch.fcgi'
  
  checkout_path = File.join(ENV['RAILS_PATH'], 'trunk')
  export_path   = "#{ENV['RAILS_PATH']}/rev_#{ENV['REVISION']}"
  symlink_path  = 'vendor/rails'

  # do we need to checkout the file?
  unless File.exists?(checkout_path)
    puts 'setting up rails trunk'    
    get_framework_for checkout_path do |framework|
      system "svn co http://dev.rubyonrails.org/svn/rails/trunk/#{framework}/lib #{checkout_path}/#{framework}/lib --quiet"
    end
  end

  # do we need to export the revision?
  unless File.exists?(export_path)
    puts "setting up rails rev #{ENV['REVISION']}"
    get_framework_for export_path do |framework|
      system "svn up #{checkout_path}/#{framework}/lib -r #{ENV['REVISION']} --quiet"
      system "svn export #{checkout_path}/#{framework}/lib #{export_path}/#{framework}/lib"
    end
  end

  puts 'linking rails'
  rm_rf   symlink_path
  mkdir_p symlink_path

  get_framework_for symlink_path do |framework|
    ln_s File.expand_path("#{export_path}/#{framework}/lib"), "#{symlink_path}/#{framework}/lib"
  end

  touch "vendor/rails_#{ENV['REVISION']}"
end

def get_framework_for(*paths)
  %w( railties actionpack activerecord actionmailer activesupport actionwebservice ).each do |framework|
    paths.each { |path| mkdir_p "#{path}/#{framework}" }
    yield framework
  end
end
