require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/comments_controller'

# Re-raise errors caught by the controller.
class Admin::CommentsController; def rescue_action(e) raise e end; end

class Admin::CommentsControllerTest < Test::Unit::TestCase
  fixtures :contents, :users, :sites, :memberships
  def setup
    @controller = Admin::CommentsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as :ben
  end

  def test_should_disable_comments_on_article
    post :close, :id => contents(:welcome).id
    assert_equal -1, contents(:welcome).reload.comment_age
    assert_response :success
  end
end
