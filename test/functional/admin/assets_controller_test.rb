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

  def test_should_upload_and_create_asset_records
    assert_difference sites(:first).assets, :count do
      assert_difference Asset, :count, 3 do # asset + 2 thumbnails
        process_upload
        assert_redirected_to asset_path
      end
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
