module AuthenticatedSystem
  protected
    def logged_in?
      (@current_user ||= session[:user] ? User.find_by_site(site, session[:user]) : :false).is_a?(User)
    end

    def current_user
      @current_user if logged_in?
    end
    
    def current_user=(new_user)
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
          redirect_to :controller=>"/account", :action =>"login"
        end
        accepts.xml { access_denied_with_basic_auth }
      end
      false
    end

    # store current uri in  the session.
    # we can return to this location by calling return_location
    def store_location
      session[:return_to] = request.request_uri
    end
    
    # move to the last store_location call or to the passed default one
    def redirect_back_or_default(default)
      session[:return_to] ? redirect_to_url(session[:return_to]) : redirect_to(default)
      session[:return_to] = nil
    end
    
    def basic_auth_required
      unless session[:user] = User.authenticate_for(*get_auth_data.unshift(site)) 
        access_denied_with_basic_auth
      end 
    end
    
    # adds ActionView helper methods
    def self.included(base)
      base.send :helper_method, :current_user, :logged_in?
    end

    # When called with before_filter :login_from_cookie will check for an :auth_token
    # cookie and log the user back in if apropriate
    def login_from_cookie
      return unless cookies[:auth_token] && !logged_in?
      user = User.find_by_remember_token(cookies[:auth_token])
      if user && user.remember_token?
        user.remember_me
        self.current_user = user
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
        flash[:notice] = "Logged in successfully"
      end
    end

  private
    def access_denied_with_basic_auth
      headers["Status"]           = "Unauthorized"
      headers["WWW-Authenticate"] = %(Basic realm="Web Password")
      render :text => "Could't authenticate you", :status => '401 Unauthorized'
    end

    # gets BASIC auth info
    def get_auth_data
      user, pass = '', '' 
      # extract authorisation credentials 
      if request.env.has_key? 'X-HTTP_AUTHORIZATION' 
        # try to get it where mod_rewrite might have put it 
        authdata = request.env['X-HTTP_AUTHORIZATION'].to_s.split 
      elsif request.env.has_key? 'HTTP_AUTHORIZATION' 
        # this is the regular location 
        authdata = request.env['HTTP_AUTHORIZATION'].to_s.split  
      end 
       
      # at the moment we only support basic authentication 
      if authdata && authdata[0] == 'Basic' 
        user, pass = Base64.decode64(authdata[1]).split(':')[0..1] 
      end 
      return [user, pass] 
    end
end