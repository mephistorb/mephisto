ActionController::Routing::Routes.draw do |map|
  map.feed    'feed/*sections', :controller => 'feed', :action => 'feed'

  map.with_options :controller => 'assets', :action => 'show' do |m|
    m.connect ':dir/:path.:ext',       :dir => /stylesheets|javascripts|images/
    m.css    'stylesheets/:path.:ext', :dir => 'stylesheets'
    m.js     'javascripts/:path.:ext', :dir => 'javascripts'
    m.images 'images/:path.:ext',      :dir => 'images'
  end
  
  map.overview 'admin/overview.xml', :controller => 'admin/overview', :action => 'feed'
  map.admin    'admin', :controller => 'admin/overview', :action => 'index'
  map.resources :assets, :path_prefix => '/admin', :controller => 'admin/assets', :collection => { :latest => :post, :search => :post, :upload => :post }
  
  map.connect ':controller/:action/:id/:version', :version => nil, :controller => /routing_navigator|account|(admin\/\w+)/
  
  map.comment ':year/:month/:day/:permalink/comment', :controller => 'comments', :action => 'create',
      :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/

  map.comment_preview ':year/:month/:day/:permalink/comment/:comment', :controller => 'comments', :action => 'show',
      :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/

  map.with_options :controller => 'mephisto' do |m|
    m.article ':year/:month/:day/:permalink', :action => 'show',    
      :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/

    m.monthly ':year/:month',                 :action => 'month', 
      :year => /\d{4}/, :month => /\d{1,2}/

    m.paged_monthly ':year/:month/page/:page', :action => 'month', 
      :year => /\d{4}/, :month => /\d{1,2}/, :page => /\d+/

    m.daily   ':year/:month/:day',            :action => 'day',  
      :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/
  
    m.yearly  ':year',                        :action => 'yearly',  
      :year => /\d{4}/
  
    m.search  'search',    :action => 'search'
    m.section '*sections', :action => 'list'
  end
end
