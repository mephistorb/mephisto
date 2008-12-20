module Mephisto
  class Routing
    # Adds Mephisto routes.  Yield a given block to allow custom routes.
    #
    #   Mephisto::Routing.connect_with map do
    #     map.foo ...
    #   end
    def self.connect_with(map)
      map.feed    'feed/*sections', :controller => 'feed', :action => 'feed'
      
      map.with_options :controller => 'assets', :action => 'show' do |m|
        m.connect ':dir/:path.:ext',       :dir => /stylesheets|javascripts|images/
        m.css    'stylesheets/:path.:ext', :dir => 'stylesheets'
        m.js     'javascripts/:path.:ext', :dir => 'javascripts'
        m.images 'images/:path.:ext',      :dir => 'images'
      end

      map.moderate 'admin/articles/comments',       :controller => 'admin/comments', :action => 'index'
      map.purge    'admin/articles/comments/purge', :controller => 'admin/comments', :action => 'destroy'

      map.resources :articles, :path_prefix => 'admin', :controller => 'admin/articles' do |r|
        r.resources :comments, :controller => 'admin/comments', :member => { :unapprove => :post, :approve => :post, :edit => :get, :preview => :post }
      end

      # Called from the asset upload sidebar's JavaScript.
      map.connect 'admin/articles/upload/:id', :controller => 'admin/articles', :action => 'upload'

      map.overview 'admin/overview.xml', :controller => 'admin/overview', :action => 'feed'
      map.admin    'admin', :controller => 'admin/overview', :action => 'index'
      map.resources :assets, :path_prefix => '/admin', :controller => 'admin/assets', :member => { :add_bucket => :post },
        :collection => { :latest => [:get, :post], :search => [:get, :post], :upload => :post, :clear_bucket => :post }
      
      # Where oh where is my xmlrpc code?
      # map.connect 'xmlrpc', :controller => 'backend', :action => 'xmlrpc' 
      
      map_from_plugins(map)
      
      map.connect(':controller/:action/:id/:version',
                  :controller => /routing_navigator|account|admin\/\w+/,
                  :action => /[^\/]*/,
                  :id => /[^\/]*/,
                  :defaults => { :version => nil })

      yield if block_given?
      
      map.dispatch '*path', :controller => 'mephisto', :action => 'dispatch'
      map.home '', :controller => 'mephisto', :action => 'dispatch'
    end
    
    class << self
      expiring_attr_reader :redirections,  '{}'
    end
    
    def self.map_from_plugins(map)
      if map.respond_to?(:from_plugin)
        Engines.plugins.each { |plugin| map.from_plugin(plugin.name) }
      else
        # This happens when running 'rake gems' under Rails 2.2 when some
        # gems are not yet installed.
        Rails.logger.warn "Cannot set up plugin routes because engines isn't loaded yet"
      end
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
      @@sanitize_path_regex = /\A(\/)|(https?:\/\/)/
      def self.sanitize_path(path)
        path =~ @@sanitize_path_regex ? path : "/#{path.split("://").last}"
      end
      
      def self.convert_redirection_to_regex(path)
        path = path.split("://").last
        path = path[1..-1] if path[0..0] == '/'
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
