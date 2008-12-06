require File.dirname(__FILE__) + '/../../test_helper'

# Re-raise errors caught by the controller.
class Admin::AssetsController; def rescue_action(e) raise e end; end

# special test suite that clears the assets table and assets
class Admin::AssetsControllerUploadTest < Test::Unit::TestCase
  fixtures :sites, :users, :assets

  def setup
    @controller = Admin::AssetsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as :quentin
    Asset.delete_all
  end

  def test_should_sort_assets
    assets_per_creation = has_image_processor? ? 3 : 1
    created = []
    assert_difference sites(:first).assets, :count, 21 do
      assert_difference Asset, :count, 21 * assets_per_creation do
        t = 5.months.ago.utc
        21.times do |i|
          Time.mock! t + i.days do
            created <<
              sites(:first).assets.create(:title => "Asset for #{Time.now.to_s(:db)}", 
                                          :uploaded_data => fixture_file_upload('assets/logo.png', 'image/png'))
          end
        end
      end
    end
    created.reverse!
    get :index
    assert_response :success
    assert_models_equal created[0..3], assigns(:recent)
    assert_models_equal created[4..-1], assigns(:assets)
  end

  def test_should_edit_asset
    login_as :quentin
    process_upload ['logo.png']
    get :edit, :id => Asset.find(:first).id
    assert_response :success
  end
  
  def test_should_update_asset
    login_as :quentin
    process_upload ['logo.png']
    post :update, :id => Asset.find(:first).id, :asset => { :title => 'foo bar' }
    assert_redirected_to assets_path
    assert_valid assigns(:asset)
    assert_equal 'foo bar', assigns(:asset).title
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
