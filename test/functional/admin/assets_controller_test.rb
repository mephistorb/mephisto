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
    Fixtures.delete_existing_fixtures_for(Asset.connection, :assets)
  end

  def test_should_visit_index
    get :index
    assert_response :success
  end

  def test_should_sort_assets
    
    assert_difference sites(:first).assets, :count, 21 do
      assert_difference Asset, :count, 63 do
        t = 5.months.ago.utc
        21.times do |i|
          Time.mock! t + i.days do
            sites(:first).assets.create(:title => "Asset for #{Time.now.to_s(:db)}", :uploaded_data => fixture_file_upload('assets/logo.png', 'image/png'))
          end
        end
      end
    end
    get :index
    assert_response :success
    assert_models_equal Asset.find(61, 58, 55, 52, :order => 'created_at desc'), assigns(:recent)
    assert_models_equal Asset.find(*((4..51).to_a.in_groups_of(3).collect(&:first) << {:order => 'created_at desc'})), assigns(:assets)
  end

  def test_should_upload_and_create_asset_records
    assert_difference sites(:first).assets, :count do
      assert_difference Asset, :count, 3 do # asset + 2 thumbnails
        process_upload
        #assert_redirected_to asset_path
      end
    end
  end
  
  def test_should_edit_asset
    login_as(:quentin) { process_upload }
    login_as :quentin
    get :edit, :id => Asset.find(1).id
    assert_response :success
  end
  
  def test_should_update_asset
    login_as(:quentin) { process_upload }
    login_as :quentin
    post :update, :id => Asset.find(1).id, :asset => { :title => 'foo bar' }
    #assert_redirected_to asset_path
    assert_valid assigns(:asset)
    assert_equal 'foo bar', assigns(:asset).title
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
