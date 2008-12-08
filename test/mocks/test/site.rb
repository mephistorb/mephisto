require File.join(RAILS_ROOT, 'app/models/site')

class Site
  attr_reader :recent_template_type, :recent_preferred_template, :recent_layout_template
  
  def call_render_with_testing(section, template_type, assigns = {}, controller = nil)
    @recent_template_type = template_type
    call_render_without_testing(section, template_type, assigns, controller)
  end
  
  def set_content_template_with_testing(section, template_type)
    @recent_preferred_template = set_content_template_without_testing(section, template_type)
  end
  
  def set_layout_template_with_testing(section, template_type)
    @recent_layout_template = set_layout_template_without_testing(section, template_type)
  end
  
  [:call_render, :set_content_template, :set_layout_template].each do |m|
    alias_method_chain m, :testing
  end
end unless Site.instance_methods.include?('call_render_with_testing')
