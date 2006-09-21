require File.join(RAILS_ROOT, 'app/models/site')

class Site
  @@theme_path = Pathname.new(RAILS_ROOT) + 'tmp/themes'
  attr_reader :recent_template_type, :recent_preferred_template, :recent_layout_template
  
  def set_template_type_for_with_testing(section, template_type)
    @recent_template_type = set_template_type_for_without_testing(section, template_type)
  end
  
  def set_content_template_with_testing(section, template_type)
    @recent_preferred_template = set_content_template_without_testing(section, template_type)
  end
  
  def set_layout_template_with_testing(section, template_type)
    @recent_layout_template = set_layout_template_without_testing(section, template_type)
  end
  
  [:set_template_type_for, :set_content_template, :set_layout_template].each do |m|
    alias_method_chain m, :testing
  end
end unless Site.instance_methods.include?('set_template_type_for_with_testing')