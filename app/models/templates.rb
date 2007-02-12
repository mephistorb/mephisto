class Templates < Attachments
  @@template_types = ["section", "single", "archive", "search", "error", "tag", "layout"]
  @@template_types.sort!

  def template_types(extension = ".liquid")
    @@template_types.collect { |f| "#{f}"+extension }
  end
  
  def [](template_name)
    template_name = File.basename(template_name.to_s).sub /#{theme.extension}$/, ''
    theme.path + "#{template_name =~ /layout$/ ? 'layouts' : 'templates'}/#{template_name}#{theme.extension}"
  end

  def collect_templates(template_type, *custom_templates)
    custom_templates.push(template_type.to_s+theme.extension).collect! { |t| self[t] }
  end

  # adds the custom_template to the top of the hierarchy if given
  def find_preferred(template_type, custom_template = nil)
    collect_templates(template_type, custom_template).detect(&:file?)
  end
  
  def custom(extension = ".liquid")
    @custom ||= (collect { |p| p.basename.to_s } - template_types(extension)).sort
  end
end