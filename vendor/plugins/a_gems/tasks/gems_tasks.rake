namespace :gems do
  task :freeze do
    raise "No gem specified" unless gem_name = ENV['GEM']

    require 'rubygems'
    Gem.manage_gems
    
    gem = (version = ENV['VERSION']) ?
      Gem.cache.search(gem_name, "= #{version}").first :
      Gem.cache.search(gem_name).sort_by { |g| g.version }.last
    
    version ||= gem.version.version rescue nil
    
    unless gem && path = Gem::UnpackCommand.new.get_path(gem_name, version)
      raise "No gem #{gem_name} #{version} is installed.  Do 'gem list #{gem_name}' to see what you have available."
    end

    target_dir = ENV['TO'] || File.basename(path).sub(/\.gem$/, '')
    rm_rf "vendor/#{target_dir}"
    
    chdir File.join(RAILS_ROOT, 'vendor') do
      mkdir_p target_dir
      Gem::Installer.new(path).unpack(target_dir)
      puts "Unpacked #{gem_name} #{version} to '#{target_dir}'"
    end
  end

  task :unfreeze do
    raise "No gem specified" unless gem_name = ENV['GEM']
    Dir["vendor/#{gem_name}-*"].each { |d| rm_rf d }
  end
end