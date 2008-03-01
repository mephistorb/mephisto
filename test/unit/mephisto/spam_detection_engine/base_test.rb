require File.dirname(__FILE__) + "/../../../test_helper"
context "Mephisto::SpamDetectionEngine::Base" do
  before do
    @site = Site.new
    @site.spam_engine_options = {:key => "a key", :url => "a url"}
    @site.save(false)
    @engine = Mephisto::SpamDetectionEngine::Base.new(@site)
  end

  specify "should raise a subclass responsibility error when calling #valid?" do
    assert_raise SubclassResponsibilityError do
      @engine.valid?
    end
  end

  specify "should raise a subclass responsibility error when calling #valid_key?" do
    assert_raise SubclassResponsibilityError do
      @engine.valid_key?
    end
  end

  specify "should raise a subclass responsibility error when calling #ham?" do
    assert_raise SubclassResponsibilityError do
      @engine.ham?(nil, nil)
    end
  end

  specify "should raise a subclass responsibility error when calling #mark_as_spam" do
    assert_raise SubclassResponsibilityError do
      @engine.mark_as_spam(nil)
    end
  end

  specify "should raise a subclass responsibility error when calling #mark_as_ham" do
    assert_raise SubclassResponsibilityError do
      @engine.mark_as_ham(nil)
    end
  end

  specify "should return an empty Hash for #statistics" do
    assert_equal Hash.new, @engine.statistics
  end
end
