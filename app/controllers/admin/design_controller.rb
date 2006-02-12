class Admin::DesignController < Admin::BaseController
  before_filter :find_templates_and_resources!

  def index
    @resource = Resource.new
  end
end
