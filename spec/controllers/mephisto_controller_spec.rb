require File.dirname(__FILE__) + '/../spec_helper'

describe MephistoController do
  controller_name "mephisto"
  integrate_views

  before :each do
    @article = Article.make
    @path = @article.full_permalink.sub(/^\//, '').split('/')
    @comment_data = { 'author' => 'Joe',
                      'author_email' => 'joe@example.com',
                      'author_url' => 'http://example.com/~joe/',
                      'body' => 'Hello!' }
  end

  def post_comment data
    post('dispatch', :path => @path + ['comments'], :comment => data)
    response.should be_redirect
    @article.reload
    @article.comments.count.should == 1
    @comment = @article.comments.first
  end

  it "should allow comments to be posted" do
    post_comment @comment_data
    @comment.author.should == 'Joe'
    @comment.author_email.should == 'joe@example.com'
    @comment.author_url.should == 'http://example.com/~joe/'
    @comment.body.should == 'Hello!'
  end

  it "should only allow specific comment fields to be set" do
    @comment_data['excerpt'] = 'Hi!'
    post_comment @comment_data
    @comment.excerpt.should be_nil
  end
end
