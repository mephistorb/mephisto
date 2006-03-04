require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/overview_controller'

# Re-raise errors caught by the controller.
class Admin::OverviewController; def rescue_action(e) raise e end; end

class Admin::OverviewControllerTest < Test::Unit::TestCase
  fixtures :users, :contents, :events, :sites
  def setup
    @controller = Admin::OverviewController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as :quentin
  end

  def test_routing
    with_options :controller => 'admin/overview' do |test|
      test.assert_routing 'admin/overview',     :action => 'index'
      test.assert_routing 'admin/overview.xml', :action => 'feed'
    end
  end

  def test_should_not_explode_on_home_page
    get :index
    assert_response :success
  end

  def test_should_not_explode_on_feed
    get :feed
    assert_response :success
  end
end
