require File.join(RAILS_ROOT, 'app/models/template')
Template.class_eval do
  def base_path
    @base_path ||= File.join(RAILS_ROOT, 'tmp/themes', "site-#{site_id}")
  end

  def destroy_file
  end
end