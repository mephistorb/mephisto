ActionController::Routing::Routes.draw do |map|
  map.admin   'admin', :controller => 'admin/base', :action => 'index'
  map.feed    'feed/*tags', :controller => 'feed', :action => 'feed'

  map.connect ':controller/:action/:id'

  map.comment ':year/:month/:day/:permalink/comment', :controller => 'comments', :action => 'create',    
      :requirements => { :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/ }

  map.with_options :controller => 'mephisto' do |map|
    map.article ':year/:month/:day/:permalink', :action => 'show',    
      :requirements => { :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/ }

    map.daily   ':year/:month/:day',            :action => 'day',  
      :requirements => { :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/ }

    map.paged_monthly ':year/:month/page/:page', :action => 'month', 
      :requirements => { :year => /\d{4}/, :month => /\d{1,2}/, :page => /\d+/ }

    map.monthly ':year/:month',                 :action => 'month', 
      :requirements => { :year => /\d{4}/, :month => /\d{1,2}/ }

    map.yearly  ':year',                        :action => 'yearly',  
      :requirements => { :year => /\d{4}/ }

    map.paged_search 'search/:q/page/:page',    :action => 'search'
    map.search  'search/:q',                    :action => 'search', :q => nil
    map.tags    '*tags',                        :action => 'list'
  end
end
