class Admin::BaseController < ApplicationController
  include AuthenticatedSystem
  before_filter { |c| UserMailer.default_url_options[:host] = c.request.host_with_port }
  before_filter :login_from_cookie
  before_filter :login_required, :except => :feed

  helper_method :admin?

  protected
    alias authorized? admin?

    def find_and_sort_templates
      @layouts, @templates = site.templates.partition { |t| t.dirname.to_s =~ /layouts$/ }
    end
    
    def self.clear_empty_templates_for(model, *attributes)
      options = attributes.last.is_a?(Hash) ? attributes.pop : {}
      before_filter(options) { |c| attributes.each { |attr| c.params[model][attr] = nil if c.params[model][attr] == '-' } }
    end
end
