ActionController::Routing::Routes.draw do |map|
  map.admin   'admin', :controller => 'admin/base', :action => 'index'

  map.connect ':controller/:action/:id'

  map.with_options :controller => 'mephisto' do |map|
    map.article ':year/:month/:day/:permalink', :action => 'show',    
      :requirements => { :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/ }

    map.daily   ':year/:month/:day',            :action => 'date',  
      :requirements => { :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/ }

    map.monthly ':year/:month',                 :action => 'date', 
      :requirements => { :year => /\d{4}/, :month => /\d{1,2}/ }

    map.yearly  ':year',                        :action => 'yearly',  
      :requirements => { :year => /\d{4}/ }

    map.search  'search/:q',                    :action => 'search', :q => nil
    map.tags    '*tags',                        :action => 'list'
  end
end
