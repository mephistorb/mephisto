require File.dirname(__FILE__) + '/../test_helper'
require 'application_helper'
require 'digest/md5'

ApplicationHelperTestController = Class.new ApplicationController do
  # look at how i mock the action view request
  def request() self end 
  def env
    @env ||= {}
  end
  def host_with_port
    'localhost:3000'
  end
end

class ApplicationHelperTest < Test::Unit::TestCase
  fixtures :assets, :users
  include ActionView::Helpers::TagHelper, ApplicationHelper, WhiteListHelper
  
  def request
    @request ||= ApplicationHelperTestController.new
    @request
  end
  
  def test_should_return_default_avatar_for_nil_users
    assert_equal 'mephisto/avatar.gif', gravatar_url_for(nil)
  end
  
  def test_should_return_gravatar_link_for_user
    expected = "http://www.gravatar.com/avatar.php?size=80&gravatar_id=#{Digest::MD5.hexdigest(users(:quentin).email)}&default=http://#{request.host_with_port}/images/mephisto/avatar.gif"
    assert_equal expected, gravatar_url_for(users(:quentin))
  end

  def test_should_return_movie_icon_for_movie
    assert_match /video\.png/, asset_image_for(assets(:mov))
  end
  
  def test_should_return_audio_icon_for_mp3
    assert_match /audio\.png/, asset_image_for(assets(:mp3))
  end
  
  def test_should_return_doc_icon_for_other
    assert_match /doc\.png/, asset_image_for(assets(:word))
  end
  
  def test_should_return_pdf_icon
    assert_match /pdf\.png/, asset_image_for(assets(:pdf))
  end

  def test_should_return_thumbnail
    assert_match assets(:gif).public_filename(:tiny), asset_image_for(assets(:gif))
  end

  def test_should_return_actual_image
    assert_match assets(:png).public_filename, asset_image_for(assets(:png))
  end

  def test_should_not_sanitize_tables
    assert_equal "&lt;table&gt;", sanitize_feed_content('<table>')
  end

  def test_should_sanitize_tables
    assert_equal "&amp;lt;table&gt;", sanitize_feed_content('<table>', true)
  end

  protected
    def asset_image_args_for(*args)
      controller.send(:asset_image_args_for, *args)
    end
    
    def controller
      @controller ||= ApplicationHelperTestController.new
    end
  
    def image_tag(path, options = {})
      tag 'img', options.merge(:src => path)
    end
end
