standard_dirs = ['rails', 'plugins']
gems          = Dir[File.join(RAILS_ROOT, "vendor/**")]
if gems.any?
  gems.each do |dir|
    next if standard_dirs.include?(File.basename(dir))
    lib = File.join(dir, 'lib')
    $LOAD_PATH.unshift(lib) if File.directory?(lib)
  end
end