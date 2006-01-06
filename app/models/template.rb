class Template < ActiveRecord::Base
  @@hierarchy = {
    :main    => [:home,   :index],
    :single  => [:single, :index],
    :tag     => [:tag,    :archive, :index],
    :archive => [:archive, :index],
    #:page    => [:page,   :index],
    #:author  => [:author, :archive, :index],
    :search  => [:search, :archive, :index],
    #:error   => [:error,  :index]
  }
  @@template_types = @@hierarchy.values.flatten.uniq << ['layout']
  cattr_reader :hierarchy, :template_types

  class << self
    def find_all_by_name(template_type)
      find(:all, :conditions => ['name IN (?)', (hierarchy[template_type] + [:layout]).collect { |v| v.to_s }])
    end

    def templates_for(template_type)
      find_all_by_name(template_type).inject({}) do |templates, template| 
        template.data.blank? ? templates : templates.merge(template.name => template.data)
      end
    end

    def find_preferred(template_type, templates = nil)
      templates ||= templates_for(template_type)
      hierarchy[template_type].each { |name| return templates[name.to_s] if templates[name.to_s] }
      nil
    end
  end
  
  def to_param
    name
  end
end