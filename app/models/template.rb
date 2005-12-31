class Template < ActiveRecord::Base
  @@hierarchy = {
    :main   => [:home,   :index],
    :single => [:single, :index],
    :tag    => [:tag,    :archive, :index],
    :page   => [:page,   :index],
    :author => [:author, :archive, :index],
    :search => [:search, :index],
    :error  => [:error,  :index]
  }
  cattr_reader :hierarchy

  class << self
    def find_all_by_name(template_type)
      find(:all, :conditions => ['name IN (?)', (hierarchy[template_type] << :layout).collect { |v| v.to_s }])
    end

    def templates_for(template_type)
      find_all_by_name(template_type).inject({}) { |templates, template| templates.merge(template.name => template.data) }
    end

    def find_preferred(template_type, templates = nil)
      templates ||= templates_for(template_type)
      hierarchy[template_type].each { |name| return templates[name.to_s] if templates[name.to_s] }
      nil
    end
  end
end