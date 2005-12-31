# Template Hierarchy (inspired by wordpress)
#   The Main Page
#   * home
#   * index
#
#   Single Post Page
#   * single
#   * index
# 
#   Tag Page
#   * tag-full/tag
#   * tag
#   * archive
#   * index
#
#   Page
#   * page
#   * index
#
#   Author Page
#   * author
#   * archive
#   * index
#
#   Date Page# 
#   * date
#   * archive
#   * index
#
#   Search Result Page
#   * search
#   * index
#
#   Error Page
#   * error
#   * index
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
      find(:all, :conditions => ['name IN (?)', hierarchy[template_type].collect { |v| v.to_s }])
    end

    def find_preferred(template_type)
      all = find_all_by_name(template_type).inject({}) { |templates, template| templates.merge(template.name => template) }
      hierarchy[template_type].each do |name|
        return all[name.to_s] if all[name.to_s]
      end
      nil
    end
  end
end