FileUtils.cp File.join(File.dirname(__FILE__), 'javascripts', 'dialog.js'), File.join(RAILS_ROOT, 'public', 'javascripts')
puts IO.read(File.join(File.dirname(__FILE__), 'README'))