ActionController::Routing::Routes.draw do |map|
  map.feed    'feed/*sections', :controller => 'feed', :action => 'feed'

  map.with_options :controller => 'assets', :action => 'show' do |m|
    m.css    'stylesheets/*path', :dir => 'stylesheets'
    m.js     'javascripts/*path', :dir => 'javascripts'
    m.images 'images/*path',      :dir => 'images'
  end

  map.overview 'admin/overview.xml', :controller => 'admin/overview', :action => 'feed'

  map.admin   'admin', :controller => 'admin/overview', :action => 'index'

  map.connect ':controller/:action/:id/:version', :version => nil, 
      :requirements => { :controller => /account|(admin\/\w+)/ }

  map.comment ':year/:month/:day/:permalink/comment', :controller => 'comments', :action => 'create',    
      :requirements => { :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/ }

  map.with_options :controller => 'mephisto' do |m|
    m.article ':year/:month/:day/:permalink', :action => 'show',    
      :requirements => { :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/ }

    m.daily   ':year/:month/:day',            :action => 'day',  
      :requirements => { :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/ }

    m.paged_monthly ':year/:month/page/:page', :action => 'month', 
      :requirements => { :year => /\d{4}/, :month => /\d{1,2}/, :page => /\d+/ }

    m.monthly ':year/:month',                 :action => 'month', 
      :requirements => { :year => /\d{4}/, :month => /\d{1,2}/ }

    m.yearly  ':year',                        :action => 'yearly',  
      :requirements => { :year => /\d{4}/ }

    m.paged_search 'search/:q/page/:page', :action => 'search'
    m.search       'search/:q',            :action => 'search', :q => nil
    m.section     '*sections',             :action => 'list'
  end
end
