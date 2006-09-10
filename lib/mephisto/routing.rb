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
    end
  end
end