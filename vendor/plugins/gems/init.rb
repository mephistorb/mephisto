gems = Dir["vendor/**"]
if gems.any?
  require 'rubygems' unless Object.const_defined?(:Gem)
  gems.each do |dir|
    next if ['rails', 'plugins'].include?(File.basename(dir))
    lib = File.join(RAILS_ROOT, dir, 'lib')
    $LOAD_PATH.unshift(lib) if File.directory?(lib)
  end
end