class Admin::BaseController < ApplicationController
  include AuthenticatedSystem
  before_filter :login_required
end
