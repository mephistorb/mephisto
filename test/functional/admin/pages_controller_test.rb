require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/pages_controller'

# Re-raise errors caught by the controller.
class Admin::PagesController; def rescue_action(e) raise e end; end

class Admin::PagesControllerTest < Test::Unit::TestCase
  def setup
    @controller = Admin::PagesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
