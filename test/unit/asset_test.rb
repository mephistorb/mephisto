require File.dirname(__FILE__) + '/../test_helper'

class AssetTest < Test::Unit::TestCase
  fixtures :sites, :assets, :tags, :taggings

  def test_should_upload_and_create_asset_records
    assert_difference sites(:first).assets, :count do
      assert_difference Asset, :count, 3 do # asset + 2 thumbnails
        process_upload
        asset = Asset.find(:first, :conditions => 'id > 7', :order => 'created_at')
        assert_equal 2, asset.thumbnails_count
      end
    end
  end

  def test_should_upload_file
    process_upload
    now = Time.now.utc
    assert_file_exists File.join(ASSET_PATH, now.year.to_s, now.month.to_s, now.day.to_s, 'logo.png')
    assert_file_exists File.join(ASSET_PATH, now.year.to_s, now.month.to_s, now.day.to_s, 'logo_thumb.png')
    assert_file_exists File.join(ASSET_PATH, now.year.to_s, now.month.to_s, now.day.to_s, 'logo_tiny.png')
  end

  def test_should_upload_file_in_multi_sites_mode
    Site.multi_sites_enabled = true
    process_upload
    now = Time.now.utc
    assert_file_exists File.join(ASSET_PATH, sites(:first).host, now.year.to_s, now.month.to_s, now.day.to_s, 'logo.png')
    assert_file_exists File.join(ASSET_PATH, sites(:first).host, now.year.to_s, now.month.to_s, now.day.to_s, 'logo_thumb.png')
    assert_file_exists File.join(ASSET_PATH, sites(:first).host, now.year.to_s, now.month.to_s, now.day.to_s, 'logo_tiny.png')
  ensure
    Site.multi_sites_enabled = false
  end

  def test_should_show_correct_public_filename
    process_upload
    now   = Time.now.utc
    asset = Asset.find(:first, :conditions => 'id > 7', :order => 'created_at')
    assert_equal File.join('/assets', now.year.to_s, now.month.to_s, now.day.to_s, 'logo.png'), asset.public_filename
  end

  def test_should_show_correct_public_filename_in_multi_sites_mode
    Site.multi_sites_enabled = true
    process_upload
    now   = Time.now.utc
    asset = Asset.find(:first, :conditions => 'id > 7', :order => 'created_at')
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
    assert_models_equal [Asset.find(:first, :conditions => 'id > 7', :order => 'created_at'), assets(:word), assets(:swf), assets(:pdf), assets(:mov), assets(:mp3), assets(:png), assets(:gif)], sites(:first).assets
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
    ['video/mpeg', 'video/quicktime', 'application/x-shockwave-flash'].each do |content_type|
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

  def test_should_report_other_type
    a = Asset.new
    ['application/pdf', 'application/msword', 'text/html', 'application/x-gzip'].each do |content_type|
      a.content_type = content_type
      assert a.other?, "#{content_type} was an image/movie/audio"
    end
  end

  def test_should_report_pdf_type
    a = Asset.new :content_type => 'application/pdf'
    assert a.pdf?, "#{a.content_type} was not a pdf"
  end

  def test_should_find_movies
    assert_models_equal [assets(:swf), assets(:mov)], Asset.find_all_by_content_types([:movie], :all, :order => 'created_at desc')
  end

  def test_should_find_audio
    assert_models_equal [assets(:mp3)], Asset.find_all_by_content_types([:audio], :all, :order => 'created_at desc')
  end

  def test_should_find_images
    assert_models_equal [assets(:png), assets(:gif)], Asset.find_all_by_content_types([:image], :all, :order => 'created_at desc')
  end

  def test_should_find_others
    assert_models_equal [assets(:word), assets(:pdf)], Asset.find_all_by_content_types([:other], :all, :order => 'created_at desc')
  end

  def test_should_find_others_and_audio
    assert_models_equal [assets(:word), assets(:pdf), assets(:mp3)], Asset.find_all_by_content_types([:audio, :other], :all, :order => 'created_at desc')
  end

  def test_should_set_tags
    assert_equal 'ruby', assets(:gif).tag
    assert_difference Tagging, :count do
      assets(:gif).update_attribute :tag, 'ruby, rails'
    end
    assert_equal 'rails, ruby', assets(:gif).reload.tag
  end

  def test_should_set_tags_upon_asset_creation
    a = nil
    assert_difference Tagging, :count, 2 do
      a = process_upload :tag => 'ruby, rails'
    end
    assert_equal 'rails, ruby', a.reload.tag
  end

  def setup
    FileUtils.mkdir_p ASSET_PATH
  end
  
  def teardown
    FileUtils.rm_rf ASSET_PATH
  end
  
  protected
    def process_upload(options = {})
      a = sites(:first).assets.create(options.reverse_merge(:filename => 'logo.png', :content_type => 'image/png', 
        :attachment_data => IO.read(File.join(RAILS_ROOT, 'public/images/logo.png'))))
      assert_valid a
      a
    end
end
