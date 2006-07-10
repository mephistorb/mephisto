# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  cattr_accessor :site_count
  before_filter  :set_cache_root
  helper_method  :site
  attr_reader    :site

  def render_liquid_template_for(template_type, assigns = {})
    headers["Content-Type"] ||= 'text/html; charset=utf-8'

    if assigns['articles'] && assigns['article'].nil?
      self.cached_references += assigns['articles']
      assigns['articles']     = assigns['articles'].collect &:to_liquid
    end

    render :text => site.templates.render_liquid_for(site, @section, template_type, assigns, self), :status => (assigns.delete(:status) || '200 OK')
  end
  
  protected
    def utc_to_local(time)
      site.timezone.utc_to_local(time)
    end

    helper_method :utc_to_local

    def set_cache_root
      @site ||= Site.find_by_host(request.host) || Site.find(:first, :order => 'id')
      # prepping for site-specific page cache directories, DONT PANIC
      #self.class.page_cache_directory = File.join([RAILS_ROOT, (RAILS_ENV == 'test' ? 'tmp' : 'public'), 'sites', site.host])
    end
end