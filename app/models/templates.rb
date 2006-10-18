class Templates < Attachments
  @@template_types = [:section, :single, :archive, :search, :error, :tag, :layout].collect! { |f| "#{f}.liquid" }
  @@template_types.sort!
  cattr_reader :template_types

  def [](template_name)
    template_name = File.basename(template_name.to_s).sub /\.liquid$/, ''
    theme.path + "#{template_name =~ /layout$/ ? 'layouts' : 'templates'}/#{template_name}.liquid"
  end

  def collect_templates(template_type, *custom_templates)
    custom_templates.push(template_type).collect! { |t| self[t] }
  end

  # adds the custom_template to the top of the hierarchy if given
  def find_preferred(template_type, custom_template = nil)
    collect_templates(template_type, custom_template).detect(&:file?)
  end
  
  def custom
    @custom ||= collect { |p| p.basename.to_s } - template_types
  end
end