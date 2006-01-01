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

  def test_should_create_article
    assert_difference Article, :count do
      xhr :post, :create, :article => { :title => "My Red Hot Car", :summary => "Blah Blah", :description => "Blah Blah" }
      assert_response :success
    end
  end

  def test_should_create_article_with_given_tags
    xhr :post, :create, :article => { :title => "My Red Hot Car", :summary => "Blah Blah", :description => "Blah Blah", :tag_ids => [tags(:home).id] }
    assert_equal [tags(:home)], assigns(:article).tags
  end
end
