require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/articles_controller'

# Re-raise errors caught by the controller.
class Admin::ArticlesController; def rescue_action(e) raise e end; end

class Admin::ArticlesControllerAssetsTest < Test::Unit::TestCase
  fixtures :contents, :content_versions, :sections, :assigned_sections, :users, :sites, :tags, :taggings, :memberships

  def setup
    @controller = Admin::ArticlesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as :quentin
    FileUtils.mkdir_p ASSET_PATH
  end

  def test_should_upload_asset
    asset_count = Object.const_defined?(:Magick) ? 3 : 1 # asset + 2 thumbnails
    
    assert_difference Asset, :count, asset_count do
      post :upload, :asset => { :uploaded_data => fixture_file_upload('assets/logo.png', 'image/png') }
      assert_response :success
      assert_template 'new'
    end
  end

  def test_should_upload_asset_and_redirect_to_article
    asset_count = Object.const_defined?(:Magick) ? 3 : 1 # asset + 2 thumbnails
    
    assert_difference Asset, :count, asset_count do
      post :upload, :id => contents(:welcome).id, 
                    :asset => { :uploaded_data => fixture_file_upload('assets/logo.png', 'image/png') }
      assert_response :success
      assert_template 'edit'
      assert_equal contents(:welcome), assigns(:article)
    end
  end

  def test_should_upload_asset_as_member
    asset_count = Object.const_defined?(:Magick) ? 3 : 1 # asset + 2 thumbnails
    
    login_as :ben
    assert_difference Asset, :count, asset_count do
      post :upload, :asset => { :uploaded_data => fixture_file_upload('assets/logo.png', 'image/png') }
      assert_response :success
      assert_template 'new'
    end
  end

  def test_should_not_upload_asset_to_other_users_article_as_member
    asset_count = Object.const_defined?(:Magick) ? 3 : 1 # asset + 2 thumbnails
    
    login_as :ben
    assert_difference Asset, :count, asset_count do
      post :upload, :id => contents(:welcome).id, 
                    :asset => { :uploaded_data => fixture_file_upload('assets/logo.png', 'image/png') }
      assert_redirected_to :controller => 'account', :action => 'login'
    end
  end

  def test_should_upload_asset_and_redirect_to_article_as_member
    asset_count = Object.const_defined?(:Magick) ? 3 : 1 # asset + 2 thumbnails
    
    login_as :ben
    assert_difference Asset, :count, asset_count do
      post :upload, :id => contents(:site_map).id, 
                    :asset => { :uploaded_data => fixture_file_upload('assets/logo.png', 'image/png') }
      assert_response :success
      assert_template 'edit'
      assert_equal contents(:site_map), assigns(:article)
    end
  end

  def test_should_not_error_on_new_article_asset_upload
    assert_no_difference Asset, :count do
      post :upload
      assert_response :success
      assert_template 'new'
    end
  end

  def test_should_not_error_on_article_asset_upload
    assert_no_difference Asset, :count do
      post :upload, :id => contents(:welcome).id
      assert_response :success
      assert_template 'edit'
      assert_equal contents(:welcome), assigns(:article)
    end
  end

  def test_should_not_create_article_when_uploading_asset
    Time.mock! Time.local(2005, 1, 1, 12, 0, 0) do
      assert_no_difference Article, :count do
        post :upload, :asset => { :uploaded_data => fixture_file_upload('assets/logo.png', 'image/png') }, 
          :article => { :title => "My Red Hot Car", :excerpt => "Blah Blah", :body => "Blah Blah",
          'published_at(1i)' => '2005', 'published_at(2i)' => '1', 'published_at(3i)' => '1', 'published_at(4i)' => '10' }, :submit => :save
        assert_response :success
        assert_template 'new'
        assert_valid assigns(:article)
        assert assigns(:article).new_record?
        assert_equal Time.local(2005, 1, 1, 9, 0, 0).utc, assigns(:article).published_at
        assert_equal users(:quentin), assigns(:article).updater
      end
    end
  end

  def teardown
    FileUtils.rm_rf ASSET_PATH
  end
end
