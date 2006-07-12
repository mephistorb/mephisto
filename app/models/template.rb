# Templates are a special type of Asset for storing liquid template data.  It defines
# special methods for retrieving the preferred template.
class Template < Attachment
  acts_as_attachment :content_type => 'text/liquid'
  validates_as_attachment
  before_validation :set_file_path_and_content_type

  @@hierarchy = {
    :main    => [:home,     :index],
    :single  => [:single,   :index],
    :section => [:section,  :archive, :index],
    :archive => [:archive,  :index],
    :page    => [:page,     :single,  :index],
    :search  => [:search,   :archive, :index],
    :author  => [:author,   :archive, :index],
    :error   => [:error,    :index]
  }
  
  @@template_types   = @@hierarchy.values.flatten.uniq << :layout
  cattr_reader :hierarchy, :template_types

  class << self
    def find_all_by_filename(template_type)
      find(:all, :conditions => ["filename IN (?)", (hierarchy[template_type] + [:layout]).collect(&:to_s)])
    end

    def templates_for(template_type)
      find_all_by_filename(template_type).inject({}) do |templates, template|
        templates.merge(template.filename => template)
      end
    end

    def find_preferred(template_type, templates = nil)
      templates ||= templates_for(template_type)
      hierarchy[template_type].each { |name| return templates[name.to_s] if templates[name.to_s] }
      nil
    end

    def render_liquid_for(site, section, template_type, assigns = {}, controller = nil)
      templates           = (section && section.template && section.layout) ? [] : templates_for(template_type)
      preferred_template  = (section && section.template) || find_preferred(template_type, templates)
      layout_template     = (section && section.layout)   || templates['layout']
      preferred_template  = preferred_template ? preferred_template.attachment_data : ''
      layout_template     = layout_template    ? layout_template.attachment_data    : ''
      assigns['site']     = site.to_liquid
      assigns['sections'] = Mephisto::Liquid::SectionsDrop.new(site)
      assigns['content_for_layout'] = Liquid::Template.parse(preferred_template).render(assigns, :registers => {:controller => controller})
      Liquid::Template.parse(layout_template).render(assigns, :registers => {:controller => controller})
    end

    def find_custom
      find(:all, :conditions => ['filename NOT IN (?)', template_types.collect(&:to_s)])
    end
  end

  def system?
    template_types.include? filename.to_sym
  end

  def layout?
    filename.to_s =~ /layout$/
  end

  def to_param
    filename
  end

  def path
    layout? ? 'layouts' : 'templates'
  end

  def full_filename(thumbnail = nil)
    File.join(base_path, path, thumbnail_name_for(thumbnail).to_s + '.liquid')
  end

  def base_path
    @base_path ||= File.join(RAILS_ROOT, 'themes', "site-#{site_id}")
  end

  protected
    def set_file_path_and_content_type
      self.content_type = 'text/liquid'
    end
end