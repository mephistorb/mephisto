require File.dirname(__FILE__) + '/../../test_helper'

# Re-raise errors caught by the controller.
class Admin::AssetsController; def rescue_action(e) raise e end; end

class Admin::AssetsControllerPermissionsTest < Test::Unit::TestCase
  fixtures :sites, :assets, :users, :contents, :memberships

  def setup
    @controller = Admin::AssetsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as :ben
  end

  def test_should_visit_index
    get :index
    assert_response :success
    assert_equal 7, assigns(:count_by_conditions)
  end
  
  def test_should_upload_and_create_asset_records
    asset_count = has_image_processor? ? 3 : 1 # asset + 2 thumbnails
    
    assert_difference sites(:first).assets, :count do
      assert_difference Asset, :count, asset_count do
        process_upload ['logo.png']
        assert_equal users(:ben).id, assigns(:assets).first.user_id
        assert_equal 'logo.png', assigns(:assets).first.title
        assert_match /logo\.png/, flash[:notice]
        assert_redirected_to assets_path
      end
    end
  end
  
  def test_should_find_recent_assets
    xhr :post, :latest
    assert_response :success
    assert_models_equal [assets(:word), assets(:swf), assets(:pdf), assets(:mov), assets(:mp3), assets(:png)], assigns(:assets)
  end
  
  def test_should_search_for_assets_by_tag_or_title_default
    xhr :post, :search, :q => 'ruby'
    assert_response :success
    assert_equal 1, assigns(:count_by_conditions)
    assert_models_equal [assets(:gif)], assigns(:assets)
  end

  def test_should_update_asset
    put :update, :id => assets(:gif).id, :asset => { :title => 'updated gif' }
    assert_redirected_to assets_path
    assert_equal 'updated gif', assets(:gif).reload.title
  end

  def test_should_not_delete_other_users_assets
    assert_no_difference Asset, :count do
      delete :destroy, :id => assets(:swf).id
      assert_redirected_to :controller => 'account', :action => 'login'
    end
  end

  def test_should_delete_asset
    assert_difference Asset, :count, -1 do
      delete :destroy, :id => assets(:gif).id
    end
  
    assert_redirected_to assets_path
    assert_not_nil flash[:notice]
  end
  
  def test_should_add_to_bucket
    xhr :post, :add_bucket, :id => assets(:gif).id
    assert_response :success
    assert_match /Flash\.notice/, @response.body
    assert_equal 1, session[:bucket].size
    assert_kind_of Array, session[:bucket][assets(:gif).id]
  end

  def test_should_clear_bucket
    @request.session[:bucket] = 'foo'
    xhr :post, :clear_bucket
    assert_response :success
    assert_nil session[:bucket]
  end

  def teardown
    FileUtils.rm_rf ASSET_PATH
  end
  
  protected
    def process_upload(files, options = {})
      FileUtils.mkdir_p ASSET_PATH
      files.collect! do |f|
        filename     = f.is_a?(Array) ? f.shift : f
        content_type = (f.is_a?(Array) && f.shift) || 'image/png'
        fixture_file_upload("assets/#{filename}", content_type)
      end
      post :create, :asset => options, :asset_data => files
    end
end
