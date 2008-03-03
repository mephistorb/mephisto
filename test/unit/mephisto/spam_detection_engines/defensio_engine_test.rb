require File.dirname(__FILE__) + "/../../../test_helper"
context "A properly configured Mephisto::SpamDetectionEngines::DefensioEngine" do
  before do
    @site = Site.new(:spam_detection_engine => "Mephisto::SpamDetectionEngines::DefensioEngine")
    @site.spam_engine_options = {:defensio_url => "http://my.blog.com/", :defensio_key => "akey"}
    @site.save(false)
    @engine = @site.spam_engine

    @request = stub("request", :host_with_port => "my.host.com")
    @article = Article.new(:published_at => 10.hours.ago)
    @comment = Comment.new(:article => @article)
    @defensio = stub("defensio client")
    @site.stub!(:permalink_for).and_return("/2008/2/17/this-is-my-permalink")
  end

  specify "should be #valid?" do
    assert @engine.valid?
  end
end

context "A properly configured Mephisto::SpamDetectionEngines::DefensioEngine" do
  before do
    @site = Site.new(:spam_detection_engine => "Mephisto::SpamDetectionEngines::DefensioEngine")
    @site.spam_engine_options = {:defensio_url => "http://my.blog.com/", :defensio_key => "akey"}
    @site.save(false)
    @engine = @site.spam_engine

    @request = stub("request", :host_with_port => "my.host.com")
    @article = Article.new(:published_at => 10.hours.ago)
    @comment = Comment.new(:article => @article)
    @defensio = stub("defensio client")
    @site.stub!(:permalink_for).and_return("/2008/2/17/this-is-my-permalink")
    Defensio::Client.stub!(:new).and_return(@defensio)
  end

  specify "should call #validate_key on #valid_key?" do
    @defensio.should_receive(:validate_key).and_return(stub("defensio response", :success? => true))
    assert @engine.valid_key?
  end

  specify "should call #report_false_positives on #mark_as_ham" do
    @comment.should_receive(:spam_engine_data).and_return(:signature => "the-signature")
    @defensio.should_receive(:report_false_positives).with(:signatures => ["the-signature"]).and_return(stub("response"))
    @engine.mark_as_ham(@request, @comment)
  end

  specify "should call #report_false_negatives on #mark_as_spam" do
    @comment.should_receive(:spam_engine_data).and_return(:signature => "a-signature")
    @defensio.should_receive(:report_false_negatives).with(:signatures => ["a-signature"]).and_return(stub("response"))
    @engine.mark_as_spam(@request, @comment)
  end

  specify "should call #audit_comment on #ham?" do
    @defensio.should_receive(:audit_comment).with(any_args).and_return(stub("defensio response", :signature => "a signature", :spaminess => "0.43", :spam => false))

    @comment.should_receive(:update_attribute).with(:spam_engine_data, {:spaminess => 0.43, :signature => "a signature"}).and_return(true)
    assert @engine.ham?(@request, @comment)
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
