require File.dirname(__FILE__) + '/../test_helper'

class AssetDropTest < ActiveSupport::TestCase
  fixtures :sites, :assets
  
  test "should report as images" do
    [:gif, :png].each { |f| assert assets(f).to_liquid.is_image }
  end
  
  test "should not report as images" do
    [:mp3, :mov, :pdf, :swf, :word].each { |f| assert !assets(f).to_liquid.is_image }
  end
  
  test "should report as movies" do
    [:swf, :mov].each { |f| assert assets(f).to_liquid.is_movie }
  end
  
  test "should not report as movies" do
    [:mp3, :gif, :pdf, :png, :word].each { |f| assert !assets(f).to_liquid.is_movie }
  end
  
  test "should report as audio" do
    [:mp3].each { |f| assert assets(f).to_liquid.is_audio }
  end
  
  test "should not report as audio" do
    [:gif, :pdf, :png, :word, :swf, :mov].each { |f| assert !assets(f).to_liquid.is_audio }
  end
  
  test "should report as other" do
    [:word, :pdf].each { |f| assert assets(f).to_liquid.is_other }
  end
  
  test "should not report as other" do
    [:mp3, :gif, :png, :swf, :mov].each { |f| assert !assets(f).to_liquid.is_other }
  end
  
  test "should report as pdf" do
    [:pdf].each { |f| assert assets(f).to_liquid.is_pdf }
  end
  
  test "should not report as pdf" do
    [:mp3, :gif, :png, :word, :swf, :mov].each { |f| assert !assets(f).to_liquid.is_pdf }
  end
end

class AssetDropTagsTest < ActiveSupport::TestCase
  fixtures :sites, :assets, :tags, :taggings
  
  test "should list tags" do
    assert_equal %w(ruby), assets(:gif).to_liquid.tags
  end
end
