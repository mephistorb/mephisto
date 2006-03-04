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
    with_options :controller => 'assets', :action => 'show' do |test|
      test.assert_routing 'stylesheets/foo/bar', :dir => 'stylesheets', :path => ['foo', 'bar']
      test.assert_routing 'stylesheets/foo.css', :dir => 'stylesheets', :path => ['foo.css']
      test.assert_routing 'images/foo/bar',      :dir => 'images',      :path => ['foo', 'bar']
      test.assert_routing 'images/foo.png' ,     :dir => 'images',      :path => ['foo.png']
      test.assert_routing 'javascripts/foo/bar', :dir => 'javascripts', :path => ['foo', 'bar']
      test.assert_routing 'javascripts/foo.js' , :dir => 'javascripts', :path => ['foo.js']
    end
  end

  def test_should_find_css_by_full_path
    get :show, :path => ['style.css'], :dir => 'stylesheets'
    assert_equal 'text/css', @response.headers['Content-Type']
    assert_equal attachments(:css).data, @response.body
  end

  def test_should_find_js_by_full_path
    get :show, :path => ['behavior.js'], :dir => 'javascripts'
    assert_equal 'text/javascript', @response.headers['Content-Type']
    assert_equal attachments(:js).data, @response.body
  end

  def test_should_find_image_by_full_path
    get :show, :path => ['users', 'quentin.png'], :dir => 'images'
    assert_equal 'image/png', @response.headers['Content-Type']
    assert_equal attachments(:quentin).data, @response.body
  end
end
