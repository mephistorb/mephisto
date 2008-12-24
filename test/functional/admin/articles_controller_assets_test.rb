require File.dirname(__FILE__) + '/../../test_helper'

# Re-raise errors caught by the controller.
class Admin::ArticlesController; def rescue_action(e) raise e end; end

class AdminArticlesControllerAssetsTest < ActiveSupport::TestCase
  fixtures :contents, :content_versions, :sections, :assigned_sections, :users, :sites, :tags, :taggings, :memberships, :assigned_assets, :assets

  def setup
    @controller = Admin::ArticlesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as :quentin
    FileUtils.mkdir_p ASSET_PATH
  end

  test "should upload asset" do
    asset_count = has_image_processor? ? 3 : 1 # asset + 2 thumbnails
    
    assert_difference Asset, :count, asset_count do
      post :upload, :asset => { :uploaded_data => fixture_file_upload('assets/logo.png', 'image/png') }
      assert_response :success
      assert_template 'new'
    end
  end

  test "should upload asset and redirect to article" do
    asset_count = has_image_processor? ? 3 : 1 # asset + 2 thumbnails
    
    assert_difference Asset, :count, asset_count do
      post :upload, :id => contents(:welcome).id, 
                    :asset => { :uploaded_data => fixture_file_upload('assets/logo.png', 'image/png') }
      assert_response :success
      assert_template 'edit'
      assert_equal contents(:welcome), assigns(:article)
    end
  end

  test "should upload asset as member" do
    asset_count = has_image_processor? ? 3 : 1 # asset + 2 thumbnails
    
    login_as :ben
    assert_difference Asset, :count, asset_count do
      post :upload, :asset => { :uploaded_data => fixture_file_upload('assets/logo.png', 'image/png') }
      assert_response :success
      assert_template 'new'
    end
  end

  test "should upload asset and redirect to article as member" do
    asset_count = has_image_processor? ? 3 : 1 # asset + 2 thumbnails
    
    login_as :ben
    assert_difference Asset, :count, asset_count do
      post :upload, :id => contents(:site_map).id, 
                    :asset => { :uploaded_data => fixture_file_upload('assets/logo.png', 'image/png') }
      assert_response :success
      assert_template 'edit'
      assert_equal contents(:site_map), assigns(:article)
    end
  end

  test "should not error on new article asset upload" do
    assert_no_difference Asset, :count do
      post :upload
      assert_response :success
      assert_template 'new'
    end
  end

  test "should not error on article asset upload" do
    assert_no_difference Asset, :count do
      post :upload, :id => contents(:welcome).id
      assert_response :success
      assert_template 'edit'
      assert_equal contents(:welcome), assigns(:article)
    end
  end

  test "should not create article when uploading asset" do
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

  test "should add asset to article" do
    assert_difference AssignedAsset, :count do
      post :attach, :id => contents(:welcome).id, :version => assets(:mov).id
    end
    assert_models_equal [assets(:gif), assets(:mp3), assets(:mov)], contents(:welcome).assets(true)
  end
  
  test "should add inactive asset to article" do
    assert_no_difference AssignedAsset, :count do
      post :attach, :id => contents(:welcome).id, :version => assets(:png).id
    end
    assert_models_equal [assets(:gif), assets(:mp3), assets(:png)], contents(:welcome).assets(true)
  end

  test "should find deactivate article assets" do
    assert_no_difference AssignedAsset, :count do
      post :detach, :id => contents(:welcome).id, :version => assets(:mp3).id
    end
    assert_models_equal [assets(:gif)], contents(:welcome).assets
  end

  test "should be able to change asset label" do
    @assignment = assigned_assets(:welcome_gif)
    post(:label, :id => @assignment.article, :version => @assignment.asset,
         :label => 'Updated label')
    assert_response :success
    @assignment.reload
    assert_equal 'Updated label', @assignment.label
  end

  def teardown
    FileUtils.rm_rf ASSET_PATH
  end
end
