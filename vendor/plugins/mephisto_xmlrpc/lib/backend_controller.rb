require 'meta_weblog_api'
require 'movable_type_api'
class BackendController < ApplicationController
  session :off

  web_service_dispatching_mode :layered
  web_service(:metaWeblog) { MetaWeblogService.new(self)  }
  web_service(:mt)         { MovableTypeService.new(self) }

  alias xmlrpc api
  
  cache_sweeper :article_sweeper, :assigned_section_sweeper, :comment_sweeper
end
