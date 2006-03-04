# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  helper_method :current_site
  def current_site
    @current_site ||= Site.find :first
  end

  def render_liquid_template_for(template_type, assigns = {})
    headers["Content-Type"] ||= 'text/html; charset=utf-8'

    unless assigns['article']
      self.cached_references += assigns['articles']
      assigns['articles']     = assigns['articles'].collect { |a| a.to_liquid }
    end
    
    assigns.update 'site' => current_site.to_liquid
    render :text => Template.render_liquid_for(template_type, assigns)
  end
end