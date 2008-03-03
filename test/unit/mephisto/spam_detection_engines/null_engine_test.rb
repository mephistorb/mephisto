require File.dirname(__FILE__) + "/../../../test_helper"
context "Mephisto::SpamDetectionEngines::NullEngine" do
  before do
    @site = Site.new
    @site.save(false)
    @engine = Mephisto::SpamDetectionEngines::NullEngine.new(@site)
  end

  specify "should always be valid" do
    assert @engine.valid?
  end

  specify "should always have valid keys" do
    assert @engine.valid_key?
  end

  specify "should always say the comment is ham" do
    assert @engine.ham?(nil, nil)
  end

  specify "should be a noop to mark as spam" do
    assert_nil @engine.mark_as_spam(nil)
  end

  specify "should be a noop to mark as ham" do
    assert_nil @engine.mark_as_ham(nil)
  end
end
