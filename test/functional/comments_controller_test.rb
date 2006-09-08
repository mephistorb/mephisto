require File.dirname(__FILE__) + '/../test_helper'
require_dependency 'comments_controller'

# Re-raise errors caught by the controller.
class CommentsController; def rescue_action(e) raise e end; end

class CommentsControllerTest < Test::Unit::TestCase
  fixtures :contents, :sites, :sections, :assigned_sections, :events

  def setup
    @controller = CommentsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_routing
    self.with_options :year => '2006', :month => '01', :day => '01', :permalink => 'foo' do |test|
      test.assert_routing '2006/01/01/foo',         :controller => 'mephisto', :action => 'show'
      test.assert_routing '2006/01/01/foo/comment', :controller => 'comments', :action => 'create'
    end
  end

  def test_should_add_comment
    assert_difference Comment, :count do
      assert_difference contents(:welcome), :comments_count do
        post :create, contents(:welcome).hash_for_permalink.merge(:comment => {
          :body      => 'test comment', 
          :author    => 'approved bob',
          :author_ip => '127.0.0.1'
        })
        assert_redirected_to comment_preview_url(contents(:welcome).hash_for_permalink(:comment => assigns(:comment), :anchor => assigns(:comment).dom_id))
        contents(:welcome).reload
      end
    end
  end

  def test_should_reject_comment_on_expired_article
    assert_no_difference Comment, :count do
      assert_no_difference contents(:another).comments, :count do
        post :create, contents(:another).hash_for_permalink.update(:comment => {
          :body      => 'test comment', 
          :author    => 'approved bob',
          :author_ip => '127.0.0.1'
        })
        assert_response :success
        contents(:another).reload
      end
    end
  end

  def test_should_add_comment_in_site
    host! 'cupcake.com'
    assert_difference Comment, :count do
      assert_difference contents(:cupcake_welcome), :comments_count do
        post :create, contents(:cupcake_welcome).hash_for_permalink.merge(:comment => {
          :body      => 'test comment', 
          :author    => 'approved bob',
          :author_ip => '127.0.0.1'
        })
        assert_redirected_to comment_preview_url(contents(:cupcake_welcome).hash_for_permalink(:comment => assigns(:comment), :anchor => assigns(:comment).dom_id))
        contents(:cupcake_welcome).reload
      end
    end
  end
  
  def test_should_not_add_comment_across_site
    host! 'cupcake.com'
    assert_no_difference Comment, :count do
      assert_no_difference contents(:welcome), :comments_count do
        assert_no_difference contents(:cupcake_welcome), :comments_count do
          post :create, contents(:welcome).hash_for_permalink.merge(:comment => {
            :body   => 'test comment', 
            :author => 'bob'
          })
          assert_response :missing
          contents(:welcome).reload
          contents(:cupcake_welcome).reload
        end
      end
    end
  end

  def test_should_not_add_comment_article_event_for_unapproved
    assert_no_event_created do
      post :create, contents(:welcome).hash_for_permalink.merge(:comment => { :body   => 'test comment', :author => 'bob' })
    end
  end

  def test_should_automatically_approve_comment
    sites(:first).update_attribute :approve_comments, true
    assert_event_created_for :welcome, 'comment' do
      post :create, contents(:welcome).hash_for_permalink.merge(:comment => { :body   => 'test comment', :author => 'bob' })
    end
  end

  def test_should_add_comment_article_event
    assert_event_created_for :welcome, 'comment' do
      post :create, contents(:welcome).hash_for_permalink.merge(:comment => { :body   => 'test comment', :author => 'approved bob' })
    end
  end

  def test_should_show_article_page_on_invalid_comment
    assert_no_difference Comment, :count do
      assert_no_difference contents(:welcome), :comments_count do
        post :create, contents(:welcome).hash_for_permalink.merge(:comment => {
          :body => 'test comment'
        })
        assert_response :success
        contents(:welcome).reload
      end
    end
  end

  def test_should_reject_missing_article_params
    post :create, :year => '2006', :month => '01', :day => '01', :permalink => 'foo'
    assert_response :missing
  end

  def test_should_reject_get_request
    get :create, contents(:welcome).hash_for_permalink
    assert_redirected_to contents(:welcome).hash_for_permalink(:controller => 'mephisto', :action => 'show')
  end

  def test_should_reject_invalid_post
    post :create, contents(:welcome).hash_for_permalink
    assert_redirected_to contents(:welcome).hash_for_permalink(:controller => 'mephisto', :action => 'show')
  end

  def test_should_show_comments_form_with_error_messages
    date = 3.days.ago
    post :create, :year => date.year, :month => date.month, :day => date.day, :permalink => 'welcome-to-mephisto', :comment => {
      :author_url => 'http://foo', :author_email => 'foo@example.com', :body => 'test'
    }
    
    assert_response :success
    
    assert_tag 'ul',   :attributes => { :id => 'comment-errors'  }
    assert_tag 'form', :attributes => { :id => 'comment-form'    }
    assert_no_tag 'p', :attributes => { :id => 'comment-message' }
    assert_tag :tag => 'form',     :descendant => { 
               :tag => 'input',    :attributes => { :type => 'text', :id => 'comment_author',       :name => 'comment[author]' } }
    assert_tag :tag => 'form',     :descendant => {                                                                                  
               :tag => 'input',    :attributes => { :type => 'text', :id => 'comment_author_url',   :name => 'comment[author_url]', :value => 'http://foo' } }
    assert_tag :tag => 'form',     :descendant => {                                                                                  
               :tag => 'input',    :attributes => { :type => 'text', :id => 'comment_author_email', :name => 'comment[author_email]', :value => 'foo@example.com' } }
    assert_tag :tag => 'form',     :descendant => { 
               :tag => 'textarea', :attributes => {                  :id => 'comment_body',         :name => 'comment[body]'  }, :content => 'test' }
  end
  
  def test_should_show_comments_message_on_article_not_accepting_comments
    date = 3.days.ago
    post :create, :year => contents(:about).published_at.year, :month => contents(:about).published_at.month, :day => contents(:about).published_at.day, :permalink => contents(:about).permalink, :comment => {
      :author_url => 'http://foo', :author_email => 'foo@example.com', :body => 'test'
    }
    
    assert_response :success
    
    assert_no_tag 'ul',   :attributes => { :id => 'comment-errors'  }
    assert_no_tag 'form', :attributes => { :id => 'comment-form'    }
    assert_no_tag 'p',    :attributes => { :id => 'comment-message' }
  end
end
