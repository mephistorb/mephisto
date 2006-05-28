# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  before_filter :set_cache_root
  helper_method :site
  
  def site
    # Redefine this method if you wish to fail on host without a site
    @site ||= Site.find_by_host(request.host) || Site.find(:first)
  end

  def render_liquid_template_for(template_type, assigns = {})
    headers["Content-Type"] ||= 'text/html; charset=utf-8'

    unless assigns['article']
      self.cached_references += assigns['articles']
      assigns['articles']     = assigns['articles'].collect { |a| a.to_liquid }
    end
    
    assigns.update 'site' => site.to_liquid
    render :text => site.templates.render_liquid_for(template_type, assigns, self)
  end
  
  protected
    def set_cache_root
      self.class.page_cache_directory = File.join([RAILS_ROOT, (RAILS_ENV == 'test' ? 'tmp' : 'public'), 'cache', site.host].compact)
    end
end