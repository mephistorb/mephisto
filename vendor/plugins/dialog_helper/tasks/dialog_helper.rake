desc "Copies the latest dialog.js to the application's public directory"
task :update_dialog_helper do
  FileUtils.cp File.join(File.dirname(__FILE__), '..', 'javascripts', 'dialog.js'), File.join(RAILS_ROOT, 'public', 'javascripts')
end