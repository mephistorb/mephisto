module AuthenticatedSystem
  protected
    def logged_in?
      current_user != :false
    end
    
    # Accesses the current user from the session.
    def current_user
      @current_user ||= (session[:user] && User.find_by_site(site, session[:user])) || :false
    end
    
    # Store the given user in the session.
    def current_user=(new_user)
      # Reset session to prevent session fixation, unless we're just
      # clearing an already-cleared user (in which case we need to keep the
      # authenticity_token valid, allowing us to handle errors on the login
      # form without authenticity errors).
      reset_session unless new_user.nil? and @current_user.nil?
      session[:user] = (new_user.nil? || new_user.is_a?(Symbol)) ? nil : new_user.id
      @current_user = new_user
    end
    
    def authorized?
      true
    end
    
    def login_required
      username, passwd = get_auth_data
      self.current_user ||= User.authenticate_for(site, username, passwd) || :false if username && passwd
      logged_in? && authorized? ? true : access_denied
    end

    def access_denied
      respond_to do |accepts|
        accepts.html do
          store_location
          redirect_to :controller => "/account", :action => "login"
        end
        accepts.xml { access_denied_with_basic_auth }
      end
      false
    end

    # store current uri in  the session.
    # we can return to this location by calling return_location
    # Options:
    # * :overwrite - (default = true) Overwrite existing stored location
    # * :uri - Return to the specified URI (defaults to request.request_uri)
    def store_location(uri = nil)
      session[:return_to] = uri || request.request_uri
    end
    
    def location_stored?
      !session[:return_to].nil?
    end

    # move to the last store_location call or to the passed default one
    def redirect_back_or_default(default)
      redirect_to(location_stored? ? session[:return_to] : default)
      session[:return_to] = nil
    end
    
    def basic_auth_required
      User.authenticate_for(*get_auth_data.unshift(site)) || access_denied_with_basic_auth
    end
    
    # adds ActionView helper methods
    def self.included(base)
      base.send :helper_method, :current_user, :logged_in?
    end

    # When called with before_filter :login_from_cookie will check for an :auth_token
    # cookie and log the user back in if apropriate
    def login_from_cookie
      return unless cookies[:token] && !logged_in?
      self.current_user = site.user_by_token(cookies[:token])
      cookies[:token] = { :value => self.current_user.reset_token! , :expires => self.current_user.token_expires_at } if logged_in?
      true
    end

  private
    def access_denied_with_basic_auth
      headers["Status"]           = "Unauthorized"
      headers["WWW-Authenticate"] = %(Basic realm="Web Password")
      render :text => "Could't authenticate you", :status => '401 Unauthorized'
    end

    @@http_auth_headers = %w(X-HTTP_AUTHORIZATION HTTP_AUTHORIZATION Authorization)
    # gets BASIC auth info
    def get_auth_data
      auth_key  = @@http_auth_headers.detect { |h| request.env.has_key?(h) }
      auth_data = request.env[auth_key].to_s.split unless auth_key.blank?
      return auth_data && auth_data[0] == 'Basic' ? Base64.decode64(auth_data[1]).split(':')[0..1] : [nil, nil] 
    end
end
