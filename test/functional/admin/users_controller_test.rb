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

  def test_should_show_deleted_users
    get :index
    assert_equal 3, assigns(:users).size
    normal_tag  = { :tag => 'li', :attributes => { :id => 'user-1', :class => 'clear' } }
    deleted_tag = { :tag => 'li', :attributes => { :id => 'user-3', :class => 'clear deleted' } }
    assert_tag normal_tag
    assert_tag 'li', :attributes => { :id => 'user-2', :class => 'clear' }
    assert_tag deleted_tag
    assert_tag    'a', :content => 'Disable', :ancestor => normal_tag
    assert_no_tag 'a', :content => 'Disable', :ancestor => deleted_tag
    assert_no_tag 'a', :content => 'Enable',  :ancestor => normal_tag
    assert_tag    'a', :content => 'Enable',  :ancestor => deleted_tag
  end

  def test_should_disable_user
    assert_no_difference User, :count_with_deleted do
      assert_difference User, :count, -1 do
        xhr :post, :destroy, :id => users(:quentin).id
        assert_response :success
      end
    end
    
    assert_equal users(:quentin), User.find_with_deleted(users(:quentin).id)
  end

  def test_should_enable_user
    assert_no_difference User, :count_with_deleted do
      assert_difference User, :count do
        xhr :post, :enable, :id => 3
        assert_response :success
      end
    end
  end
end
