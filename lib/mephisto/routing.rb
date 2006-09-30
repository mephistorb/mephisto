module Mephisto
  class Routing
    def self.connect_with(map)
      map.feed    'feed/*sections', :controller => 'feed', :action => 'feed'
      
      map.with_options :controller => 'assets', :action => 'show' do |m|
        m.connect ':dir/:path.:ext',       :dir => /stylesheets|javascripts|images/
        m.css    'stylesheets/:path.:ext', :dir => 'stylesheets'
        m.js     'javascripts/:path.:ext', :dir => 'javascripts'
        m.images 'images/:path.:ext',      :dir => 'images'
      end
      
      map.overview 'admin/overview.xml', :controller => 'admin/overview', :action => 'feed'
      map.admin    'admin', :controller => 'admin/overview', :action => 'index'
      map.resources :assets, :path_prefix => '/admin', :controller => 'admin/assets', :member => { :add_bucket => :post },
        :collection => { :latest => :post, :search => :post, :upload => :post, :clear_bucket => :post }
      
      map.connect 'xmlrpc', :controller => 'backend', :action => 'xmlrpc' 
      
      map.connect ':controller/:action/:id/:version', :version => nil, :controller => /routing_navigator|account|(admin\/\w+)/
      
      map.dispatch '*path', :controller => 'mephisto', :action => 'dispatch'
      map.home '', :controller => 'mephisto', :action => 'dispatch'
    end
    
    def self.redirections
      @redirections ||= {}
    end
    
    def self.deny(*paths)
      paths.each do |path|
        redirections[convert_redirection_to_regex(path)] = :deny
      end
    end
    
    def self.redirect(options)
      options.each do |key, value|
        redirections[convert_redirection_to_regex(key)] = sanitize_path(value)
      end
    end

    def self.handle_redirection(path)
      redirections.each do |pattern, action|
        if match = pattern.match(path)
          if action == :deny
            return [:not_found]
          else
            return [:moved_permanently, {:location => build_destination(action.dup, match)}]
          end
        end
      end
      nil
    end
    
    protected
      def self.sanitize_path(path)
        path =~ /^(\/)|(https?:\/\/)/ ? path : "/#{path.split("://").last}"
      end
      
      def self.convert_redirection_to_regex(path)
        path = path.split("://").last
        path = path[1..-1] if path.starts_with('/')
        path = Regexp.escape(path)
        path.gsub! /\//, "\\/"
        path.gsub! /(\\\*)|(\\\?$)/, "(.*)"
        path.gsub! /\\\?/, "([^\\/]+)"
        Regexp.new("^#{path}$")
      end
      
      def self.build_destination(path, matches)
        i = -1
        path.gsub!(/\$\d+/) { |s| matches[s[1..-1].to_i] }
        path.gsub!(/[^:]\/\//, &:first)
        path.chomp!('/')
        path
      end
  end
end