require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/assets_controller'

# Re-raise errors caught by the controller.
class Admin::AssetsController; def rescue_action(e) raise e end; end

class Admin::AssetsControllerTest < Test::Unit::TestCase
  fixtures :sites, :assets, :users

  def setup
    @controller = Admin::AssetsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as :quentin
  end

  def test_should_visit_index
    get :index
    assert_response :success
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
    assert_models_equal [assets(:swf), assets(:mov)], assigns(:recent)
  end

  def test_should_search_for_movies_and_other
    xhr :get, :index, :filter => { :movie => '1', :other => '1' }
    assert_response :success
    assert_models_equal [assets(:word), assets(:swf), assets(:pdf), assets(:mov)], assigns(:recent)
  end

  def test_should_search_for_movies_by_title
    xhr :get, :index, :filter => { :movie => '1' }, :q => 'swf'
    assert_response :success
    assert_models_equal [assets(:swf)], assigns(:recent)
  end

  def test_should_search_for_assets_by_title
    xhr :get, :index, :q => 'swf'
    assert_response :success
    assert_models_equal [assets(:swf)], assigns(:recent)
  end
  
  def test_should_search_for_images_by_tag
    xhr :get, :index, :q => 'ruby', :filter => { :image => '1' }, :conditions => { :tags => '1' }
    assert_response :success
    assert_models_equal [assets(:gif)], assigns(:recent)
  end

  def test_should_search_for_images_by_title
    xhr :get, :index, :q => 'swf', :filter => { :image => '1' }
    assert_response :success
    assert_equal [], assigns(:recent)
  end

  #def test_should_search_for_images_by_title_and_tag
  #  
  #end

  def teardown
    FileUtils.rm_rf ASSET_PATH
  end
  
  protected
    def process_upload
     FileUtils.mkdir_p ASSET_PATH
     post :create, :asset => { :uploaded_data => fixture_file_upload('assets/logo.png', 'image/png') }
    end
end
