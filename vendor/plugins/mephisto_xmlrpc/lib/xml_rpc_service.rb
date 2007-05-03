class XmlRpcService < ActionWebService::Base
  attr_accessor :controller
  delegate :site, :to => :controller

  def initialize(controller)
    @controller = controller
  end

  protected
    def server_url
      controller.url_for(:only_path => false, :controller => "/")
    end
    
    def pub_date(time)
      time.strftime "%a, %e %b %Y %H:%M:%S %Z"
    end
    
    def authenticate(name, args)
      method = self.class.web_service_api.api_methods[name]
    
      # Coping with backwards incompatibility change in AWS releases post 0.6.2
      begin
        h = method.expects_to_hash(args)
        raise "Invalid login" unless @user = User.authenticate_for(controller.site, h[:username], h[:password])
      rescue NoMethodError
        username, password = method[:expects].index(:username=>String), method[:expects].index(:password=>String)
        raise "Invalid login" unless @user = User.authenticate_for(controller.site, args[username], args[password])
      end
    end
end