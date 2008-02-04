require File.dirname(__FILE__) + '/../spec_helper'


describe Comment, "previewing" do
  define_models do
    time 2007, 6, 15

    model Site do
      stub :cupcake, :title => "Cupcake", :host => 'cupcake.com'
    end
    model Article do
      stub :welcome, :title => "Welcome!", :body => "Hi there", :filter => "textile_filter", :site => all_stubs(:site), :created_at => current_time - 3.days, :published_at => current_time - 2.days, :comment_age => 0
    end
  end
    
  before do
    @comment = Comment.new :author => "1", :author_ip => "127.0.0.1", :body => "No answer"
    @comment.article = contents(:welcome)
  end
  
  it "should be valid" do
    @comment.should be_valid
  end
  
  it "raises Previewing error when preview accessor is set" do
    @comment.preview = true
    lambda{
      @comment.save!
    }.should raise_error(Comment::Previewing)
  end

end

describe Comment, "textilizing" do
  define_models do
    model Site do
      stub :cupcake, :title => "Cupcake", :host => 'cupcake.com'
    end
    model Article do
      stub :welcome, :title => "Welcome!", :body => "Hi there", :filter => "textile_filter", :site => all_stubs(:site), :created_at => current_time - 3.days, :published_at => current_time - 2.days, :comment_age => 0
    end
  end
   
  # Copied from tests, in the hope that more people will PDI and convert the test::unit
  # tests to RSpec. 
  it "processes comments with textile, if the article is textile-formatted" do
    @comment = Comment.new :author => "1", :author_ip => "127.0.0.1", :body => "*test* comment"
    @comment.article = contents(:welcome)
    @comment.save
    @comment.body_html.should == "<p><strong>test</strong> comment</p>"
  end

end