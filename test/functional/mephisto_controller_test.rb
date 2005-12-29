require File.dirname(__FILE__) + '/../test_helper'
require 'mephisto_controller'

# Re-raise errors caught by the controller.
class MephistoController; def rescue_action(e) raise e end; end

class MephistoControllerTest < Test::Unit::TestCase
  fixtures :articles, :tags, :taggings

  def setup
    @controller = MephistoController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_routing
    assert_routing '', :controller => 'mephisto', :action => 'list', :tags => []
    assert_routing 'about', :controller => 'mephisto', :action => 'list', :tags => ['about']
  end

  def test_list_by_tags
    get :list, :tags => []
    assert_equal tags(:home), assigns(:tag)
    assert_equal [articles(:another).attributes, articles(:welcome).attributes], assigns(:articles)
    get :list, :tags => %w(about)
    assert_equal tags(:about), assigns(:tag)
    assert_equal [articles(:welcome).attributes], assigns(:articles)
  end
end
