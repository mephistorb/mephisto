require 'meta_weblog_api'
class BackendController < ApplicationController
  session :off

  web_service_dispatching_mode :layered
  web_service(:metaWeblog)  { MetaWeblogService.new(self) }

  alias xmlrpc api
end
