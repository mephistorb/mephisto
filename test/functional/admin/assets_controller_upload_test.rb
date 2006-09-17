require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/assets_controller'

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
    Fixtures.delete_existing_fixtures_for(Asset.connection, :assets)
  end

if Object.const_defined?(:Magick)
  def test_should_sort_assets
    assert_difference sites(:first).assets, :count, 21 do
      assert_difference Asset, :count, 63 do
        t = 5.months.ago.utc
        21.times do |i|
          Time.mock! t + i.days do
            sites(:first).assets.create(:title => "Asset for #{Time.now.to_s(:db)}", 
                                        :uploaded_data => fixture_file_upload('assets/logo.png', 'image/png'))
          end
        end
      end
    end
    get :index
    assert_response :success
    assert_models_equal Asset.find(61, 58, 55, 52, :order => 'created_at desc'), assigns(:recent)
    assert_models_equal Asset.find(*(((4..51).to_a << 1).in_groups_of(3).collect(&:first) << {:order => 'created_at desc'})), assigns(:assets)
  end
else
  def test_should_sort_assets
    old_count = Asset.count
    assert_difference sites(:first).assets, :count, 21 do
      assert_difference Asset, :count, 21 do
        t = 5.months.ago.utc
        21.times do |i|
          Time.mock! t + i.days do
            sites(:first).assets.create(:title => "Asset for #{Time.now.to_s(:db)}", 
                                        :uploaded_data => fixture_file_upload('assets/logo.png', 'image/png'))
          end
        end
      end
    end
    get :index
    assert_response :success
    assert_models_equal Asset.find(*((18..21).to_a.collect { |n| n + old_count } << {:order => 'created_at desc'})), assigns(:recent)
    assert_models_equal Asset.find(*((01..17).to_a.collect { |n| n + old_count } << {:order => 'created_at desc'})), assigns(:assets)
  end
end

  def test_should_edit_asset
    login_as :quentin
    process_upload ['logo.png']
    get :edit, :id => Asset.find(1).id
    assert_response :success
  end
  
  def test_should_update_asset
    login_as :quentin
    process_upload ['logo.png']
    post :update, :id => Asset.find(1).id, :asset => { :title => 'foo bar' }
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
