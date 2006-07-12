require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/users_controller'

# Re-raise errors caught by the controller.
class Admin::UsersController; def rescue_action(e) raise e end; end

class Admin::UsersControllerTest < Test::Unit::TestCase
  fixtures :users, :attachments, :sites
  def setup
    @controller = Admin::UsersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as :quentin
  end

  def test_should_not_explode_on_index
    get :index
    assert_response :success
  end

  def test_should_create_user
    assert_difference User, :count do
      post :create, :user => { :login => 'bob', :email => 'foo', :password => 'testy', :password_confirmation => 'testy' }
      assert_equal assigns(:user), User.authenticate('bob', 'testy')
      assert_redirected_to :action => 'index'
      assert flash[:notice]
    end
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

  def test_should_show_error_while_updating
    post :update, :id => users(:quentin).login, :user => { :email => 'foo', :password => 'tea', :password_confirmation => '' }
    users(:quentin).reload
    assert_equal 'quentin@example.com', users(:quentin).email
    assert_equal users(:quentin), User.authenticate('quentin', 'quentin')
    assert_response :success
    assert_template 'show'
  end

  def test_should_show_error_while_creating
    post :create, :user => { :email => 'foo', :password => 'tea', :password_confirmation => '' }
    assert_response :success
    assert_template 'new'
  end

  def test_should_not_upload_nonexistent_file
    assert_no_attachment_created { test_should_update_email_and_password }
  end

  def test_should_show_correct_form_action
    get :show, :id => 'quentin'
    assert_tag :tag => 'form', :attributes => { :action => '/admin/users/update/quentin' }
  end

  def test_should_highlight_correct_filter
    get :show, :id => 'quentin'
    assert_tag :tag => 'select', :attributes => { :id => 'user_filters' },
      :descendant => { :tag => 'option', :attributes => { :selected => 'selected', :value => 'textile_filter' } }
    get :show, :id => 'arthur'
    assert_tag :tag => 'select', :attributes => { :id => 'user_filters' },
      :descendant => { :tag => 'option', :attributes => { :selected => 'selected', :value => 'markdown_filter' } }
  end

  def test_should_save_new_filter
    post :update, :id => 'quentin', :user => { :filters => ['markdown_filter'] }
    users(:quentin).reload
    assert_equal :markdown_filter, users(:quentin).filters.first
  end
end
