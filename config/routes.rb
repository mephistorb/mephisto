ActionController::Routing::Routes.draw do |map|
  map.connect ':controller/:action/:id'
  map.article ':year/:month/:day/:permalink', :controller => 'mephisto', :action => 'show'
  map.search  'search/:q', :controller => 'mephisto', :action => 'search', :q => nil
  map.tags    '*tags', :controller => 'mephisto', :action => 'list'
end
