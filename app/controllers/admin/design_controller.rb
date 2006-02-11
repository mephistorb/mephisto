class Admin::DesignController < Admin::BaseController
  def index
    @templates = Template.find :all
  end
end
