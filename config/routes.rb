ActionController::Routing::Routes.draw do |map|
  map.connect ':controller/:action/:id'
  map.tags    '*tags', :controller => 'articles', :action => 'list'
end
