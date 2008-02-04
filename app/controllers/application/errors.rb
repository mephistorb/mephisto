# Custom handlers for exceptions are defined here.
class ApplicationController

  protected 
  
    # Handle public-facing errors by rendering the "error" liquid template
    def show_404
      show_error 'Page Not Found', :not_found
    end

    def show_error(message = 'An error occurred.', status = :internal_server_error)
      render_liquid_template_for(:error, 'message' => message, :status => status)
    end

    # Handle admin-application errors
    # TODO: after rails 2.0.2, convert these to rescue_from [array] rather than 3 lines.
    rescue_from ActiveRecord::RecordNotFound,        :with => :render_admin_not_found
    rescue_from ActionController::UnknownController, :with => :render_admin_not_found
    rescue_from ActionController::UnknownAction,     :with => :render_admin_not_found

    def render_admin_not_found
      # TODO: render this from the site's custom admin 404 file, if it's a multi-site install.
      render :file => File.join(RAILS_ROOT, 'public/404.html'), :status => :not_found
    end
  
    def render_admin_error
      # TODO: render this from the site's custom 500 file, if it's a multi-site install
      render :file => File.join(RAILS_ROOT, 'public/500.html'), :status => :internal_server_error
    end
  
    def rescue_action_in_public(exception)
      logger.debug "#{exception.class.name}: #{exception.to_s}"
      exception.backtrace.each { |t| logger.debug " > #{t}" }
      render_admin_error
    end  

end