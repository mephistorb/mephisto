require File.join(RAILS_ROOT, 'app/models/site')
Site.class_eval do
  def attachment_base_path
    @attachment_base_path ||= File.join(RAILS_ROOT, 'tmp/themes', "site-#{id}")
  end
end