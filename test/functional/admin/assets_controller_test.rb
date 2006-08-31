require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/assets_controller'

# Re-raise errors caught by the controller.
class Admin::AssetsController; def rescue_action(e) raise e end; end

class Admin::AssetsControllerTest < Test::Unit::TestCase
  fixtures :sites, :assets, :users, :tags, :taggings, :contents

  def setup
    @controller = Admin::AssetsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as :quentin
  end

  def test_should_visit_index
    get :index
    assert_response :success
    assert_equal 7, assigns(:count_by_conditions)
  end

  def test_should_upload_and_create_asset_records
    assert_difference sites(:first).assets, :count do
      assert_difference Asset, :count, 3 do # asset + 2 thumbnails
        process_upload
        #assert_redirected_to asset_path
      end
    end
  end

  def test_should_search_for_movies
    xhr :get, :index, :filter => { :movie => '1' }
    assert_response :success
    assert_equal 2, assigns(:count_by_conditions)
    assert_models_equal [assets(:swf), assets(:mov)], assigns(:recent)
  end

  def test_should_search_for_movies_and_other
    xhr :get, :index, :filter => { :movie => '1', :other => '1' }
    assert_response :success
    assert_equal 4, assigns(:count_by_conditions)
    assert_models_equal [assets(:word), assets(:swf), assets(:pdf), assets(:mov)], assigns(:recent)
  end

  def test_should_search_for_movies_by_title
    xhr :get, :index, :filter => { :movie => '1' }, :q => 'swf'
    assert_response :success
    assert_equal 1, assigns(:count_by_conditions)
    assert_models_equal [assets(:swf)], assigns(:recent)
  end

  def test_should_search_for_assets_by_title
    xhr :get, :index, :q => 'swf'
    assert_response :success
    assert_equal 1, assigns(:count_by_conditions)
    assert_models_equal [assets(:swf)], assigns(:recent)
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

  def test_should_search_for_images_by_tag
    xhr :get, :index, :q => 'ruby', :filter => { :image => '1' }, :conditions => { :tags => '1' }
    assert_response :success
    assert_equal 1, assigns(:count_by_conditions)
    assert_models_equal [assets(:gif)], assigns(:recent)
  end

  def test_should_search_for_images_by_title
    xhr :get, :index, :q => 'swf', :filter => { :image => '1' }
    assert_response :success
    assert_equal 0, assigns(:count_by_conditions)
    assert_equal [], assigns(:recent)
  end

  def test_should_delete_asset
    assert_difference Asset, :count, -1 do
      delete :destroy, :id => assets(:gif).id
    end
    # fixed in edge
    #assert_redirected_to assets_path
    assert_not_nil flash[:notice]
  end

  def test_should_delete_asset_and_remove_from_bucket
    @request.session[:bucket] = {assets(:gif).public_filename => []}
    delete :destroy, :id => assets(:gif).id
    assert session[:bucket].empty?
  end

  def test_should_add_to_bucket
    xhr :post, :add_bucket, :id => assets(:gif).id
    assert_response :success
    assert_match /Flash\.notice/, @response.body
    assert_equal 1, session[:bucket].size
    assert_kind_of Array, session[:bucket][assets(:gif).public_filename]
  end

  def test_should_not_add_duplicate_asset_to_bucket
    @request.session[:bucket] = {assets(:gif).public_filename => []}
    xhr :post, :add_bucket, :id => assets(:gif).id
    assert_response :success
    assert_equal ' ', @response.body
    assert_equal 1, session[:bucket].size
    assert_kind_of Array, session[:bucket][assets(:gif).public_filename]
  end

  def test_should_clear_bucket
    @request.session[:bucket] = 'foo'
    xhr :post, :clear_bucket
    assert_response :success
    assert_nil session[:bucket]
  end

  def test_should_render_form_on_invalid_create
    assert_no_difference Asset, :count do
      post :create
      assert_response :success
      assert_template 'new'
    end
  end

  def teardown
    FileUtils.rm_rf ASSET_PATH
  end
  
  protected
    def process_upload
     FileUtils.mkdir_p ASSET_PATH
     post :create, :asset => { :uploaded_data => fixture_file_upload('assets/logo.png', 'image/png') }
    end
end
