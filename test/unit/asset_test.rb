require File.dirname(__FILE__) + '/../test_helper'

ASSET_PATH = File.join(RAILS_ROOT, 'test/fixtures/assets')
class AssetTest < Test::Unit::TestCase
  fixtures :sites, :assets

  def test_should_upload_file
    process_upload
    now = Time.now
    assert File.file?(File.join(ASSET_PATH, sites(:first).host, now.year.to_s, now.month.to_s, now.day.to_s, 'logo.png'))
    assert File.file?(File.join(ASSET_PATH, sites(:first).host, now.year.to_s, now.month.to_s, now.day.to_s, 'logo_thumb.png'))
    assert File.file?(File.join(ASSET_PATH, sites(:first).host, now.year.to_s, now.month.to_s, now.day.to_s, 'logo_tiny.png'))
  end

  def test_should_set_site_id
    process_upload
    Asset.find(:all).each do |asset|
      assert_equal sites(:first).id, asset.site_id
    end
  end
  
  def test_should_ignore_thumbnails
    process_upload
    assert_equal [Asset.find_by_filename('logo.png')], sites(:first).assets
  end

  def test_should_report_image_type
    a = Asset.new
    Technoweenie::ActsAsAttachment.content_types.each do |content_type|
      a.content_type = content_type
      assert a.image?
    end
  end

  def setup
    FileUtils.mkdir_p ASSET_PATH
  end
  
  def teardown
    FileUtils.rm_rf ASSET_PATH
  end
  
  protected
    def process_upload
      assert_difference sites(:first).assets, :count do
        assert_difference Asset, :count, 3 do # asset + 2 thumbnails
          sites(:first).assets.create(:filename => 'logo.png', :content_type => 'image/png', 
            :attachment_data => IO.read(File.join(RAILS_ROOT, 'public/images/logo.png')))
        end
      end
    end
end
