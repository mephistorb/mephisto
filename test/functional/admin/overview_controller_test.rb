require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/overview_controller'

# Re-raise errors caught by the controller.
class Admin::OverviewController; def rescue_action(e) raise e end; end

class Admin::OverviewControllerTest < Test::Unit::TestCase
  fixtures :users, :contents, :events, :sites, :memberships
  def setup
    @controller = Admin::OverviewController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as :quentin
  end

  def test_routing
    with_options :controller => 'admin/overview' do |test|
      test.assert_routing 'admin',     :action => 'index'
      test.assert_routing 'admin/overview.xml', :action => 'feed'
    end
  end

  def test_should_allow_site_admins_to_access_site
    login_as :arthur
    get :index
    assert_response :success
  end

  def test_should_allow_site_members_to_acces_overview
    login_as :ben
    get :index
    assert_response :success
  end

  def test_should_not_explode_on_home_page
    get :index
    assert_response :success
  end

  def test_should_require_http_auth_on_feed
    get :feed
    assert_response 401
  end

  def test_should_require_http_auth_on_feed
    @request.env['HTTP_AUTHORIZATION'] = "Basic #{Base64.encode64("quentin:test")}"
    get :feed
    assert_response :success
  end

  def test_should_sort_future_items_in_todays_events
    today = Time.now.utc
    assert events(:future).update_attribute(  :created_at, today + 2.days)
    assert events(:site_map).update_attribute(:created_at, today - 5.minutes)
    assert events(:about).update_attribute(   :created_at, today - 1.day)
    get :index
    assert assigns(:todays_events).include?(events(:future)),    "#{assigns(:todays_events).collect(&:id).inspect}"
    assert assigns(:todays_events).include?(events(:site_map)),  "#{assigns(:todays_events).collect(&:id).inspect}"
    assert assigns(:yesterdays_events).include?(events(:about)), "#{assigns(:yesterdays_events).collect(&:id).inspect}"
  end
end
