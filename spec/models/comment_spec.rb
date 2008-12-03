require File.dirname(__FILE__) + '/../spec_helper'

describe Comment do
  it "should be valid" do
    Comment.make.should be_valid
  end
  
  it "raises Previewing error when preview accessor is set" do
    lambda {
      Comment.make(:preview => true)
    }.should raise_error(Comment::Previewing)
  end

  # Copied from tests, in the hope that more people will PDI and convert
  # the test::unit tests to RSpec.
  it "processes comments with textile, if the article is textile-formatted" do
    @comment = Comment.make(:body => "*test* comment")
    @comment.body_html.should == "<p><strong>test</strong> comment</p>"
  end
end
