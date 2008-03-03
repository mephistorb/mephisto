require File.dirname(__FILE__) + "/../../../test_helper"
context "A properly configured Mephisto::SpamDetectionEngines::DefensioEngine" do
  before do
    @site = Site.new(:spam_detection_engine => "Mephisto::SpamDetectionEngines::DefensioEngine")
    @site.spam_engine_options = {:defensio_url => "http://my.blog.com/", :defensio_key => "akey"}
    @site.save(false)
    @engine = @site.spam_engine

    @request = stub("request", :host_with_port => "")
    @comment = Comment.new
    @defensio = stub("defensio client")
    @site.stub!(:permalink_for).and_return("")
  end

  specify "should be #valid?" do
    assert @engine.valid?
  end

  specify "should instantiate a Defensio when calling #ham?" do
    Defensio::Client.should_receive(:new).and_return(@defensio)
    @engine.ham?(@request, @comment)
  end
end

context "A Mephisto::SpamDetectionEngines::DefensioEngine" do
  before do
    @site = Site.new(:spam_detection_engine => "Mephisto::SpamDetectionEngines::DefensioEngine")
    @site.spam_engine_options = {}
    @site.save(false)
    @engine = @site.spam_engine
  end

  specify "should not be #valid? when the defensio key is missing from the options" do
    @site.spam_engine_options.delete(:defensio_key)
    @site.save(false)
    assert !@site.spam_engine.valid?
  end
  
  specify "should not be #valid? when the defensio url is missing from the options" do
    @site.spam_engine_options.delete(:defensio_url)
    @site.save(false)
    assert !@site.spam_engine.valid?
  end
end

context "A Mephisto::SpamDetectionEngines::DefensioEngine instantiated from a Site with a missing :defensio_key" do
  before do
    @site = Site.new(:spam_detection_engine => "Mephisto::SpamDetectionEngines::DefensioEngine")
    @site.spam_engine_options = {:defensio_url => "http://my.blog.com/"}
    @site.save(false)
    @engine = @site.spam_engine
  end

  specify "should raise a NotConfigured exception when calling #ham?" do
    assert_raise Mephisto::SpamDetectionEngine::NotConfigured do
      @site.spam_engine.ham?(nil, nil)
    end
  end

  specify "should raise a NotConfigured exception when calling #mark_as_spam" do
    assert_raise Mephisto::SpamDetectionEngine::NotConfigured do
      @site.spam_engine.mark_as_spam(nil, nil)
    end
  end

  specify "should raise a NotConfigured exception when calling #mark_as_ham" do
    assert_raise Mephisto::SpamDetectionEngine::NotConfigured do
      @site.spam_engine.mark_as_ham(nil, nil)
    end
  end
end
