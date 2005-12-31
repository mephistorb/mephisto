require File.dirname(__FILE__) + '/../test_helper'
require 'mephisto_controller'

# Re-raise errors caught by the controller.
class MephistoController; def rescue_action(e) raise e end; end

class MephistoControllerTest < Test::Unit::TestCase
  fixtures :articles, :tags, :taggings, :templates

  def setup
    @controller = MephistoController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_routing
    assert_routing '', :controller => 'mephisto', :action => 'dispatch', :tags => []
    assert_routing 'about', :controller => 'mephisto', :action => 'dispatch', :tags => ['about']
  end

  def test_list_by_tags
    get :dispatch, :tags => []
    assert_equal tags(:home), assigns(:tag)
    assert_equal [articles(:another).attributes, articles(:welcome).attributes], assigns(:articles)
    get :dispatch, :tags => %w(about)
    assert_equal tags(:about), assigns(:tag)
    assert_equal [articles(:welcome).attributes], assigns(:articles)
  end

  def test_should_render_liquid_templates
    get :dispatch, :tags => []
    assert_tag :tag => 'h1', :content => 'This is the layout'
    assert_tag :tag => 'p',  :content => 'home'
    get :dispatch, :tags => %w(about)
    assert_tag :tag => 'p',  :content => 'tag'
  end
end
