require File.dirname(__FILE__) + '/../test_helper'
require_dependency 'feed_controller'

# Re-raise errors caught by the controller.
class FeedController; def rescue_action(e) raise e end; end

class FeedControllerTest < Test::Unit::TestCase
  fixtures :contents, :sections, :assigned_sections, :sites
  
  def setup
    @controller = FeedController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_feed_assigns
    get :feed, :sections => ['about']
    assert_equal sections(:about), assigns(:section)
    assert_equal [contents(:welcome), contents(:about), contents(:site_map)], assigns(:articles)
  end
  
  def test_feed_comes_from_site
    @request.host = 'cupcake.host'    
    get :feed, :sections => ['about']
    assert_equal sections(:cupcake_about), assigns(:section)
    assert_equal [contents(:cupcake_welcome)], assigns(:articles)
  end
  
  def test_site_in_feed_links
    @request.host = 'cupcake.host'
    get :feed, :sections => []
    assert_equal sections(:cupcake_home), assigns(:section)
    assert_equal [contents(:cupcake_welcome)], assigns(:articles)
    assert_tag :tag => 'link', :attributes => {:href => 'http://cupcake.host/'}
  end
end
