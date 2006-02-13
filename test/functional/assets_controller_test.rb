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

  def test_should_find_css_by_full_path
    get :show, :path => %w(stylesheets style.css)
    assert_equal 'text/css', @response.headers['Content-Type']
    assert_equal attachments(:css).data, @response.body
  end

  def test_should_find_js_by_full_path
    get :show, :path => %w(javascripts behavior.js)
    assert_equal 'text/javascript', @response.headers['Content-Type']
    assert_equal attachments(:js).data, @response.body
  end

  def test_should_find_image_by_full_path
    get :show, :path => %w(images foobar.png)
    assert_equal 'image/png', @response.headers['Content-Type']
    assert_equal attachments(:quentin).data, @response.body
  end
end
