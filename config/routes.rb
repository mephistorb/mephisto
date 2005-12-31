ActionController::Routing::Routes.draw do |map|
  map.connect ':controller/:action/:id'
  map.search  'search/:q', :controller => 'mephisto', :action => 'search', :q => nil
  map.tags    '*tags', :controller => 'mephisto', :action => 'list'
end
