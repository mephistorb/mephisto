require File.dirname(__FILE__) + '/../test_helper'
require 'assets_controller'

# Re-raise errors caught by the controller.
class AssetsController; def rescue_action(e) raise e end; end

class AssetsControllerTest < Test::Unit::TestCase
  fixtures :attachments

  def setup
    @controller = AssetsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_routing
    {:stylesheets => :css, :images => :png, :javascripts => :js}.each do |dir, ext|
      assert_routing "#{dir}/foo/bar",    :controller => 'assets', :action => 'show', :dir => dir.to_s, :path => %w(foo bar)
      assert_routing "#{dir}/foo.#{ext}", :controller => 'assets', :action => 'show', :dir => dir.to_s, :path => ["foo.#{ext}"]
    end
  end

  def test_should_find_css_by_full_path
    get :show, :path => ['style.css'], :dir => 'stylesheets'
    assert_equal 'text/css', @response.headers['Content-Type']
    assert_equal attachments(:css).attachment_data, @response.body
  end

  def test_should_find_js_by_full_path
    get :show, :path => ['behavior.js'], :dir => 'javascripts'
    assert_equal 'text/javascript', @response.headers['Content-Type']
    assert_equal attachments(:js).attachment_data, @response.body
  end

  # need an image
  #def test_should_find_image_by_full_path
  #  get :show, :path => ['users', 'quentin.png'], :dir => 'images'
  #  assert_equal 'image/png', @response.headers['Content-Type']
  #  assert_equal attachments(:quentin).attachment_data, @response.body
  #end
  
  def test_should_show_404_on_bad_asset
    get :show, :path => ['foo', 'bar'], :dir => 'images'
    assert_response :missing
  end
end
