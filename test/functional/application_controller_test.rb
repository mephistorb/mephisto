require File.dirname(__FILE__) + '/../test_helper'
require 'account_controller'

# Re-raise errors caught by the controller.
class AccountController
  def rescue_action(e) raise e end
  def test_host
    render :text => 'success'
  end
end

class ApplicationControllerTest < Test::Unit::TestCase
  fixtures :sites
  def setup
    @sub   = Site.create!(:title => 'sub', :host => 'sub.test.host')
    @uk    = Site.create!(:title => 'sub', :host => 'sub.test.co.uk')
    @controller = AccountController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_find_site_by_host
    host! 'test.host'
    get :test_host
    assert_equal sites(:first), @controller.site
  end

  def test_should_find_site_with_www_prefix
    host! 'www.test.host'
    get :test_host
    assert_equal sites(:first), @controller.site
  end
  
  def test_should_find_site_by_subdomain_and_host
    host! 'sub.test.host'
    get :test_host
    assert_equal @sub, @controller.site
  end
  
  def test_should_find_site_by_subdomain_and_host_with_www_prefix
    host! 'www.sub.test.host'
    get :test_host
    assert_equal @sub, @controller.site
  end
  
  def test_should_find_site_by_uk_subdomain_and_host
    host! 'sub.test.co.uk'
    get :test_host
    assert_equal @uk, @controller.site
  end
  
  def test_should_find_site_by_uk_subdomain_and_host_with_www_prefix
    host! 'www.sub.test.co.uk'
    get :test_host
    assert_equal @uk, @controller.site
  end
  
  def test_should_return_nil_user_from_invalid_http_auth_data
    get :test_host
    @controller.send(:get_auth_data).each { |value| assert_nil value }
  end
end
