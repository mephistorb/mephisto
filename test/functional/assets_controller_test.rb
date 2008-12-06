require File.dirname(__FILE__) + '/../test_helper'

# Re-raise errors caught by the controller.
class AssetsController; def rescue_action(e) raise e end; end

class AssetsControllerTest < Test::Unit::TestCase
  fixtures :sites
  def setup
    prepare_theme_fixtures
    @controller = AssetsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_routing
    {:stylesheets => :css, :images => :png, :javascripts => :js}.each do |dir, ext|
      assert_routing "#{dir}/foo.#{ext}", :controller => 'assets', :action => 'show', :dir => dir.to_s, :path => "foo", :ext => ext.to_s
    end
  end

  def test_should_find_css_by_full_path
    get :show, :path => 'style', :ext => 'css', :dir => 'stylesheets'
    assert_equal 'text/css', @response.content_type
    assert_equal sites(:first).resources['style.css'].read, @response.body
  end

  def test_should_find_js_by_full_path
    get :show, :path => 'behavior', :ext => 'js', :dir => 'javascripts'
    assert_equal Mime::JS, @response.content_type
    assert_equal sites(:first).resources['behavior.js'].read, @response.body
  end
end
