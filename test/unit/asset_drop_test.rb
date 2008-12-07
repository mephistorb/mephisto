require File.dirname(__FILE__) + '/../test_helper'

context "Asset Drop" do
  fixtures :sites, :assets
  
  it "should report as images" do
    [:gif, :png].each { |f| assert assets(f).to_liquid.is_image }
  end
  
  it "should not report as images" do
    [:mp3, :mov, :pdf, :swf, :word].each { |f| assert !assets(f).to_liquid.is_image }
  end
  
  it "should report as movies" do
    [:swf, :mov].each { |f| assert assets(f).to_liquid.is_movie }
  end
  
  it "should not report as movies" do
    [:mp3, :gif, :pdf, :png, :word].each { |f| assert !assets(f).to_liquid.is_movie }
  end
  
  it "should report as audio" do
    [:mp3].each { |f| assert assets(f).to_liquid.is_audio }
  end
  
  it "should not report as audio" do
    [:gif, :pdf, :png, :word, :swf, :mov].each { |f| assert !assets(f).to_liquid.is_audio }
  end
  
  it "should report as other" do
    [:word, :pdf].each { |f| assert assets(f).to_liquid.is_other }
  end
  
  it "should not report as other" do
    [:mp3, :gif, :png, :swf, :mov].each { |f| assert !assets(f).to_liquid.is_other }
  end
  
  it "should report as pdf" do
    [:pdf].each { |f| assert assets(f).to_liquid.is_pdf }
  end
  
  it "should not report as pdf" do
    [:mp3, :gif, :png, :word, :swf, :mov].each { |f| assert !assets(f).to_liquid.is_pdf }
  end
end

context "Asset Drop Tags" do
  fixtures :sites, :assets, :tags, :taggings
  
  it "should list tags" do
    assert_equal %w(ruby), assets(:gif).to_liquid.tags
  end
end
