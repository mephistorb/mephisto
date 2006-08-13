require File.dirname(__FILE__) + '/../test_helper'

class AssetTest < Test::Unit::TestCase
  fixtures :sites, :assets

  def test_should_upload_and_create_asset_records
    assert_difference sites(:first).assets, :count do
      assert_difference Asset, :count, 3 do # asset + 2 thumbnails
        process_upload
      end
    end
  end

  def test_should_upload_file
    process_upload
    now = Time.now
    assert_file_exists File.join(ASSET_PATH, now.year.to_s, now.month.to_s, now.day.to_s, 'logo.png')
    assert_file_exists File.join(ASSET_PATH, now.year.to_s, now.month.to_s, now.day.to_s, 'logo_thumb.png')
    assert_file_exists File.join(ASSET_PATH, now.year.to_s, now.month.to_s, now.day.to_s, 'logo_tiny.png')
  end

  def test_should_upload_file_in_multi_sites_mode
    Site.multi_sites_enabled = true
    process_upload
    now = Time.now
    assert_file_exists File.join(ASSET_PATH, sites(:first).host, now.year.to_s, now.month.to_s, now.day.to_s, 'logo.png')
    assert_file_exists File.join(ASSET_PATH, sites(:first).host, now.year.to_s, now.month.to_s, now.day.to_s, 'logo_thumb.png')
    assert_file_exists File.join(ASSET_PATH, sites(:first).host, now.year.to_s, now.month.to_s, now.day.to_s, 'logo_tiny.png')
  ensure
    Site.multi_sites_enabled = false
  end

  def test_should_show_correct_public_filename
    process_upload
    now   = Time.now
    asset = Asset.find(1)
    assert_equal File.join('/assets', now.year.to_s, now.month.to_s, now.day.to_s, 'logo.png'), asset.public_filename
  end

  def test_should_show_correct_public_filename_in_multi_sites_mode
    Site.multi_sites_enabled = true
    process_upload
    now   = Time.now
    asset = Asset.find(1)
    assert_equal File.join('/assets', now.year.to_s, now.month.to_s, now.day.to_s, 'logo.png'), asset.public_filename
  ensure
    Site.multi_sites_enabled = false
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
      assert a.image?, "#{content_type} was not an image"
    end
  end

  def test_should_report_movie_type
    a = Asset.new
    ['video/mpeg', 'video/quicktime'].each do |content_type|
      a.content_type = content_type
      assert a.movie?, "#{content_type} was not a movie"
    end
  end

  def test_should_report_audio_type
    a = Asset.new
    ['audio/mpeg', 'application/ogg', 'audio/wav'].each do |content_type|
      a.content_type = content_type
      assert a.audio?, "#{content_type} was not audio"
    end
  end

  def test_should_report_document_type
    a = Asset.new
    ['application/pdf', 'application/msword', 'text/html', 'application/x-gzip'].each do |content_type|
      a.content_type = content_type
      assert a.document?, "#{content_type} was not a document"
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
      sites(:first).assets.create(:filename => 'logo.png', :content_type => 'image/png', 
        :attachment_data => IO.read(File.join(RAILS_ROOT, 'public/images/logo.png')))
    end
end
