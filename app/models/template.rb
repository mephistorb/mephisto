# Templates are a special type of Asset for storing liquid template data.  It defines
# special methods for retrieving the preferred template.
class Template < Attachment
  include Attachment::TemplateAndResourceMixin
  acts_as_attachment :content_type => 'text/liquid'
  before_validation :set_file_path_and_content_type

  @@hierarchy = {
    :main     => [:home,     :index],
    :single   => [:single,   :index],
    :section => [:section, :archive, :index],
    :archive  => [:archive,  :index],
    :page     => [:page,     :single, :index],
    :search   => [:search,   :archive, :index]
    #:author  => [:author, :archive, :index],
    #:error   => [:error,  :index]
  }
  @@template_types = @@hierarchy.values.flatten.uniq << :layout
  cattr_reader :hierarchy, :template_types

  class << self
    def find_all_by_filename(template_type)
      find_with_data(:all, :conditions => ['filename IN (?)', (hierarchy[template_type] + [:layout]).collect { |v| v.to_s }])
    end

    def templates_for(template_type)
      find_all_by_filename(template_type).inject({}) do |templates, template|
        template.data.blank? ? templates : templates.merge(template.filename => template.data)
      end
    end

    def find_preferred(template_type, templates = nil)
      templates ||= templates_for(template_type)
      hierarchy[template_type].each { |name| return templates[name.to_s] if templates[name.to_s] }
      nil
    end
  end

  def to_param
    filename
  end

  protected
  def set_file_path_and_content_type
    self.path         = 'templates'
    self.content_type = 'text/liquid'
  end
end