require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/assets_controller'

# Use assets controller because #new is a very simple action and we just want to test the layout
class Admin::AssetsController; def rescue_action(e) raise e end; end

class Admin::AdminNavTest < Test::Unit::TestCase
  fixtures :sites, :users, :memberships

  def setup
    @controller = Admin::AssetsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as :quentin
    get :new
  end
  
  def test_should_show_primary_nav
    assert_select "#header #nav a" do |anchors|
      assert_equal %w(Overview Articles Assets), anchors[0..2].collect { |a| a.children.first.content }
    end
  end
  
  def test_should_show_secondary_nav
    assert_select "#header #nav #nav-r a" do |anchors|
      assert_equal %w(Sections Design Users), anchors.collect { |a| a.children.first.content }
    end
  end
  
  def test_should_show_user_nav
    assert_select "#header #sec-nav a" do |anchors|
      assert_equal %w(Website Settings Account Logout), anchors.collect { |a| a.children.first.content }
    end
  end
end

class Admin::MemberNavTest < Test::Unit::TestCase
  fixtures :sites, :users, :memberships

  def setup
    @controller = Admin::AssetsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as :ben
    get :new
  end
  
  def test_should_show_primary_nav
    assert_select "#header #nav a" do |anchors|
      assert_equal %w(Overview Articles Assets), anchors[0..2].collect { |a| a.children.first.content }
    end
  end
  
  def test_should_not_show_secondary_nav
    assert_raises Test::Unit::AssertionFailedError do
      assert_select "#header #nav #nav-r"
    end
  end
  
  def test_should_show_user_nav
    assert_select "#header #sec-nav a" do |anchors|
      assert_equal %w(Website Account Logout), anchors.collect { |a| a.children.first.content }
    end
  end
end
