require File.dirname(__FILE__) + '/../test_helper'
context "Site" do
  fixtures :sites, :contents, :sections

  specify "should return the null spam detection engine when none configured" do
    assert_kind_of Mephisto::SpamDetectionEngine::Null, Site.new.spam_engine
  end

  specify "should return the Mephisto::SpamDetectionEngine::Defensio engine when the spam_detection_engine column has value 'defensio'" do
    assert_kind_of Mephisto::SpamDetectionEngine::Defensio, Site.new(:spam_detection_engine => "defensio").spam_engine
  end

  specify "should serialize spam_engine_options" do
    options = {:an_options => :a_value, :another_option => nil}
    site = Site.new(:spam_engine_options => options)
    site.save(false)
    assert_equal options, site.reload.spam_engine_options
  end
end
