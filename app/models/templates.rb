class Templates < Attachments
  @@hierarchy = {
    :section => [:section,  :archive, :index],
    :page    => [:page,     :single,  :index],
    :single  => [:single,   :index],
    :archive => [:archive,  :index],
    :search  => [:search,   :archive, :index],
    :error   => [:error,    :index],
    :tag     => [:tag,      :archive, :index],
    :layout  => [:layout]
  }

  @@template_types = (@@hierarchy.values.flatten.uniq << :layout).collect! { |f| "#{f}.liquid" }
  @@template_types.sort!
  cattr_reader :hierarchy, :template_types

  def [](template_name)
    template_name = File.basename(template_name.to_s).sub /\.liquid$/, ''
    theme.path + "#{template_name =~ /layout$/ ? 'layouts' : 'templates'}/#{template_name}.liquid"
  end

  def collect_templates(template_type, custom_template = nil)
    templates = hierarchy[template_type].dup
    templates.unshift(custom_template) if custom_template
    templates.collect! { |t| self[t] }
  end

  # adds the custom_template to the top of the hierarchy if given
  def find_preferred(template_type, custom_template = nil)
    collect_templates(template_type, custom_template).detect(&:file?)
  end
  
  def custom
    @custom ||= collect { |p| p.basename.to_s } - template_types
  end
end