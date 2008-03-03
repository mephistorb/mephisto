require File.dirname(__FILE__) + "/../../../test_helper"

context "A properly configured Mephisto::SpamDetectionEngines::AkismetEngine" do
  before do
    @site = Site.new(:spam_detection_engine => "Mephisto::SpamDetectionEngines::AkismetEngine")
    @site.spam_engine_options = {:akismet_url => "http://my.blog.com/", :akismet_key => "alongkey"}
    @site.save(false)
    @engine = @site.spam_engine

    @request = stub("request", :host_with_port => "")
    @comment = Comment.new
    @akismet = stub("akismet", :comment_check => false)
  end

  specify "should be #valid?" do
    assert @engine.valid?
  end

  specify "should instantiate an Akismet when calling #ham?" do
    Akismet.should_receive(:new).and_return(@akismet)
    @engine.ham?("http://permalink.url/", @comment)
  end
end
  
context "An Mephisto::SpamDetectionEngines::AkismetEngine" do
  before do
    @site = Site.new(:spam_detection_engine => "Mephisto::SpamDetectionEngines::AkismetEngine")
    @site.spam_engine_options = {}
    @site.save(false)
    @engine = @site.spam_engine
  end

  specify "should not be #valid? when the akismet key is missing from the options" do
    @site.spam_engine_options.delete(:akismet_key)
    @site.save(false)
    assert !@site.spam_engine.valid?
  end
  
  specify "should not be #valid? when the akismet url is missing from the options" do
    @site.spam_engine_options.delete(:akismet_url)
    @site.save(false)
    assert !@site.spam_engine.valid?
  end
end

context "A Mephisto::SpamDetectionEngines::AkismetEngine instantiated from a Site with a missing :akismet_key" do
  before do
    @site = Site.new(:spam_detection_engine => "Mephisto::SpamDetectionEngines::AkismetEngine")
    @site.spam_engine_options = {:akismet_url => "http://my.blog.com/"}
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
