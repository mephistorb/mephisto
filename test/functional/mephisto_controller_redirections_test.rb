require File.dirname(__FILE__) + '/../test_helper'

# Re-raise errors caught by the controller.
class MephistoController; def rescue_action(e) raise e end; end

context "Mephisto Controller Redirections" do
  fixtures :sites

  def setup
    @controller = MephistoController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  specify "should handle denied requests" do
    %w(deny/foo/bar deny/foo/bar/baz limited_deny deny/bar/baz/blah).each { |path| assert_denied path }
  end

  specify "should redirect without variable matches" do
    assert_redirected_to '/to/here', 'redirect/from/here'
    assert_redirected_to '/bar',     'sanitize/path'
  end
  
  specify "should redirect with unused variable matches" do
    assert_redirected_to 'http://external', 'redirect/external'
  end
  
  specify "should redirect with wildcard match" do
    assert_redirected_to '/this/foo',     'redirect/match/wildcard/foo'
    assert_redirected_to '/this/foo/bar', 'redirect/match/wildcard/foo/bar'
  end

  specify "should redirect and match multiple vars" do
    assert_redirected_to '/this/bar/foo',     'redirect/match/vars/foo/bar'
    assert_redirected_to '/this/bar/baz/foo', 'redirect/match/vars/foo/bar/baz'
  end
  
  protected
    def assert_denied(path)
      dispatch path
      assert_equal :redirect, assigns(:dispatch_action)
      assert_response :missing
    end

    def assert_redirected_to(expected, path)
      dispatch path
      assert_equal :redirect, assigns(:dispatch_action)
      super expected
      assert_response 301
    end

    def dispatch(path = '', options = {})
      path = path[1..-1] if path.starts_with('/')
      get :dispatch, options.merge(:path => path.split('/'))
    end
end
