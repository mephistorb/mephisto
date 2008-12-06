require File.dirname(__FILE__) + '/../../test_helper'

# Re-raise errors caught by the controller.
class Admin::ArticlesController; def rescue_action(e) raise e end; end

class Admin::ArticlesControllerPreviewTest < Test::Unit::TestCase
  fixtures :contents, :sections, :assigned_sections, :users, :sites
  def setup
    @controller = Admin::ArticlesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as :quentin
    prepare_theme_fixtures
  end

  def test_show_action_previews_article
    get :show, :id => contents(:welcome).id
    assert_response :success
  end

  def test_show_action_previews_article_draft
    contents(:welcome).update_attribute :published_at, nil
    get :show, :id => contents(:welcome).id
    assert_response :success
  end
end
