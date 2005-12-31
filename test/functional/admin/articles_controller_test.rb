require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/articles_controller'

# Re-raise errors caught by the controller.
class Admin::ArticlesController; def rescue_action(e) raise e end; end

class Admin::ArticlesControllerTest < Test::Unit::TestCase
  fixtures :articles, :tags, :taggings

  def setup
    @controller = Admin::ArticlesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_show_articles
    get :index
    assert_equal 2, assigns(:articles).length
  end
end
