require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/settings_controller'

# Re-raise errors caught by the controller.
class Admin::SettingsController; def rescue_action(e) raise e end; end

class Admin::SettingsControllerTest < Test::Unit::TestCase
  fixtures :sites, :users
  def setup
    @controller = Admin::SettingsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as :quentin
  end

  def test_should_show_settings
    get :index
    assert_tag 'input', :attributes => { :id => 'site_title', :value => sites(:first).title }
  end

  def test_should_update_settings
    post :update, :site => { :title => 'foo' }
    assert_equal 'foo', sites(:first).title
    assert_redirected_to :action => 'index'
  end
end
