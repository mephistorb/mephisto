require File.dirname(__FILE__) + '/../../test_helper'

# Re-raise errors caught by the controller.
class Admin::ArticlesController; def rescue_action(e) raise e end; end

class Admin::ArticlesControllerPermissionsTest < Test::Unit::TestCase
  fixtures :contents, :content_versions, :sections, :assigned_sections, :users, :sites, :memberships

  def setup
    @controller = Admin::ArticlesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as :ben
  end

  def test_should_show_articles
    get :index
    assert_equal 12, assigns(:articles).length
  end

  def test_should_show_new_article_form
    get :new
    assert_response :success
  end

  def test_should_create_article
    Time.mock! Time.local(2005, 1, 1, 12, 0, 0) do
      assert_difference Article, :count do
        post :create, :article => { :title => "My Red Hot Car", :excerpt => "Blah Blah", :body => "Blah Blah",
          'published_at(1i)' => '2005', 'published_at(2i)' => '1', 'published_at(3i)' => '1', 'published_at(4i)' => '10' }, :submit => :save
        assert_redirected_to :action => 'edit', :id => assigns(:article)
        assert  assigns(:article).published?
        assert_equal Time.local(2005, 1, 1, 9, 0, 0).utc, assigns(:article).published_at
        assert !assigns(:article).new_record?
        assert_equal users(:ben), assigns(:article).updater
      end
    end
  end

  def test_should_edit_own_article
    get :edit, :id => contents(:site_map).id
    assert_response :success
  end
  
  def test_should_update_own_article_with_correct_time
    Time.mock! Time.local(2005, 1, 1, 12, 0, 0) do
      post :update, :id => contents(:site_map).id, :article => { 'published_at(1i)' => '2005', 'published_at(2i)' => '1', 'published_at(3i)' => '1', 'published_at(4i)' => '10' }
      assert  assigns(:article).published?
      assert_equal Time.local(2005, 1, 1, 9, 0, 0).utc, assigns(:article).published_at
    end
  end

  def test_should_edit_other_article
    get :edit, :id => contents(:welcome).id
    assert_response :success
  end
  
  def test_should_update_other_article_with_correct_time
    Time.mock! Time.local(2005, 1, 1, 12, 0, 0) do
      post :update, :id => contents(:welcome).id, :article => { 'published_at(1i)' => '2005', 'published_at(2i)' => '1', 'published_at(3i)' => '1', 'published_at(4i)' => '10' }
      assert  assigns(:article).published?
      assert_equal Time.local(2005, 1, 1, 9, 0, 0).utc, assigns(:article).published_at
    end
  end
  
  def test_should_destroy_own_article
    assert_difference Content, :count, -1 do
      xhr :delete, :destroy, :id => contents(:site_map).id
      assert_response :success
    end
  end
  
  def test_should_not_destroy_other_article
    assert_no_difference Content, :count do
      xhr :delete, :destroy, :id => contents(:welcome).id
      assert_response :redirect
    end
  end
end
