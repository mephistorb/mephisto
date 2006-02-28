require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/users_controller'

# Re-raise errors caught by the controller.
class Admin::UsersController; def rescue_action(e) raise e end; end

class Admin::UsersControllerTest < Test::Unit::TestCase
  fixtures :users, :attachments, :db_files
  def setup
    @controller = Admin::UsersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as :quentin
  end

  def test_should_update_email_and_password
    post :update, :id => users(:quentin).login, :user => { :email => 'foo', :password => 'testy', :password_confirmation => 'testy' }
    users(:quentin).reload
    assert_equal 'foo', users(:quentin).email
    assert_equal users(:quentin), User.authenticate('quentin', 'testy')
    assert_redirected_to :action => 'show', :id => users(:quentin).login
  end

  def test_should_leave_password_alone
    post :update, :id => users(:quentin).login, :user => { :email => 'foo', :password => '', :password_confirmation => '' }
    users(:quentin).reload
    assert_equal 'foo', users(:quentin).email
    assert_equal users(:quentin), User.authenticate('quentin', 'quentin')
    assert_redirected_to :action => 'show', :id => users(:quentin).login
  end

  def test_should_show_error
    post :update, :id => users(:quentin).login, :user => { :email => 'foo', :password => 'tea', :password_confirmation => '' }
    users(:quentin).reload
    assert_equal 'quentin@example.com', users(:quentin).email
    assert_equal users(:quentin), User.authenticate('quentin', 'quentin')
    assert_response :success
    assert_template 'show'
  end

  def test_should_not_upload_nonexistent_file
    assert_no_attachment_created { test_should_update_email_and_password }
  end

  def test_should_upload_avatar
    assert_attachment_created do
      post :update, :id => users(:quentin).login, :user => { :email => 'foo', :password => 'testy', :password_confirmation => 'testy' }, :avatar => file_upload
      users(:quentin).reload
      assert_equal 'foo', users(:quentin).email
      assert_equal users(:quentin), User.authenticate('quentin', 'testy')
      assert_redirected_to :action => 'show', :id => users(:quentin).login
    end
  end

  def test_should_show_correct_form_action
    get :show, :id => 'quentin'
    assert_tag :tag => 'form', :attributes => { :action => '/admin/users/update/quentin' }
  end

  def test_should_highlight_correct_filter
    get :show, :id => 'quentin'
    assert_tag :tag => 'select', :attributes => { :id => 'user_filters' },
      :descendant => { :tag => 'option', :attributes => { :selected => 'selected' }, :content => 'textile' }
    get :show, :id => 'arthur'
    assert_tag :tag => 'select', :attributes => { :id => 'user_filters' },
      :descendant => { :tag => 'option', :attributes => { :selected => 'selected' }, :content => 'markdown' }
  end

  def test_should_save_new_filter
    post :update, :id => 'quentin', :user => { :filters => ['markdown'] }
    assert_equal 'textile', users(:quentin).filters.first
  end
end
