require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/users_controller'

# Re-raise errors caught by the controller.
class Admin::UsersController; def rescue_action(e) raise e end; end

class Admin::UsersControllerTest < Test::Unit::TestCase
  fixtures :users, :sites, :memberships
  def setup
    @controller = Admin::UsersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_allow_site_admin
    login_as :arthur
    get :index
    assert_response :success
  end
  
  def test_should_restrict_site_member
    login_as :arthur, :hostess
    get :index
    assert_redirected_to :controller => 'account', :action => 'login'
  end

  def test_should_allow_site_member_to_view_profile
    login_as :arthur, :hostess
    get :show, :id => users(:arthur).id.to_s
    assert_response :success
  end

  def test_should_not_explode_on_index
    login_as :quentin
    get :index
    assert_response :success
  end

  def test_should_create_user
    login_as :quentin
    assert_difference User, :count do
      assert_difference Membership, :count do
        post :create, :user => { :login => 'bob', :email => 'foo@example.com', :password => 'testy', :password_confirmation => 'testy', :admin => true }
        assert_models_equal [sites(:first)], assigns(:user).sites
        assert_equal assigns(:user), User.authenticate_for(sites(:first), 'bob', 'testy')
        assert_redirected_to :action => 'index'
        assert flash[:notice]
      end
    end
  end

  def test_should_update_email_and_password
    login_as :quentin
    post :update, :id => users(:quentin).id, :user => { :email => 'foo@example.com', :password => 'testy', :password_confirmation => 'testy' }
    users(:quentin).reload
    assert_equal 'foo@example.com', users(:quentin).email
    assert_equal users(:quentin), User.authenticate_for(sites(:first), 'quentin', 'testy')
    assert_response :success
  end

  def test_should_update_email_and_password_as_site_member
    login_as :arthur, :hostess
    post :update, :id => users(:arthur).id, :user => { :email => 'foo@example.com', :password => 'testy', :password_confirmation => 'testy' }
    users(:arthur).reload
    assert_equal 'foo@example.com', users(:arthur).email
    assert_equal users(:arthur), User.authenticate_for(sites(:hostess), 'arthur', 'testy')
    assert_response :success
  end

  def test_should_leave_password_alone
    login_as :quentin
    post :update, :id => users(:quentin).id, :user => { :email => 'foo@example.com', :password => '', :password_confirmation => '' }
    users(:quentin).reload
    assert_equal 'foo@example.com', users(:quentin).email
    assert_equal users(:quentin), User.authenticate_for(sites(:first), 'quentin', 'test')
    assert_response :success
  end

  def test_should_show_error_while_updating
    login_as :quentin
    post :update, :id => users(:quentin).id, :user => { :email => 'foo@example.com', :password => 'tea', :password_confirmation => '' }
    users(:quentin).reload
    assert_equal 'quentin@example.com', users(:quentin).email
    assert_equal users(:quentin), User.authenticate_for(sites(:first), 'quentin', 'test')
    assert_response :success
  end

  def test_should_show_error_while_creating
    login_as :quentin
    post :create, :user => { :email => 'foo@example.com', :password => 'tea', :password_confirmation => '' }
    assert_response :success
  end

  def test_should_show_correct_form_action
    login_as :quentin
    get :show, :id => users(:quentin).id
    assert_tag :tag => 'form', :attributes => { :action => '/admin/users/update/1' }
  end

  def test_should_highlight_correct_filter
    login_as :quentin
    get :show, :id => users(:quentin).id
    assert_tag :tag => 'select', :attributes => { :id => 'user_filter' },
      :descendant => { :tag => 'option', :attributes => { :selected => 'selected', :value => 'textile_filter' } }
    get :show, :id => users(:arthur).id
    assert_tag :tag => 'select', :attributes => { :id => 'user_filter' },
      :descendant => { :tag => 'option', :attributes => { :selected => 'selected', :value => 'markdown_filter' } }
  end

  def test_should_save_new_filter
    login_as :quentin
    post :update, :id => '1', :user => { :filter => 'markdown_filter' }
    users(:quentin).reload
    assert_equal 'markdown_filter', users(:quentin).filter
  end

  def test_should_not_permit_promoting_self_to_admin_in_update
    login_as :arthur, :hostess
    assert !users(:arthur).admin, "we mean to test with a non-admin user"
    post :update, :id => users(:arthur).id, :user => { :admin => 'true' }
    users(:arthur).reload
    assert !users(:arthur).admin, "user.admin shouldn't change"
    assert_response :success
  end

  def test_should_not_permit_changing_own_created_at_in_update
    login_as :arthur, :hostess
    prev_time = users(:arthur).created_at
    post :update, :id => users(:arthur).id, :user => { :created_at => prev_time - 1.year }
    users(:arthur).reload
    assert_equal prev_time, users(:arthur).created_at, "user.created_at shouldn't change"
    assert_response :success
  end

  def test_should_not_permit_changing_owned_articles_in_update
    login_as :quentin
    user = users(:quentin)
    prev_article_ids = user.article_ids
    assert prev_article_ids.size > 2, "Test needs more than 2 articles. Pick another user?"
    #but now we're going to try to own only the first 2 of them...
    post :update, :id => user.id, :user => { :article_ids => prev_article_ids[0..1] }
    user.reload
    assert_equal prev_article_ids, user.article_ids, "user.article_ids[] shouldn't change"
    assert_response :success
  end

  def test_should_show_deleted_users
    login_as :quentin
    get :index
    assert_equal 4, assigns(:users).size
    assert_select "#users li[id='user-1']" do
      assert_select "[class='clear']"
    end
    assert_select "#users li[id='user-2']" do
      assert_select "[class='clear']"
    end
    assert_select "#disabled_users li[id='user-3']" do
      assert_select "[class='clear deleted']"
    end
  end

  def test_should_not_disable_as_site_member
    login_as :arthur, :hostess
    assert_no_difference User, :count do
      xhr :post, :destroy, :id => users(:arthur).id
      assert_redirected_to :controller => 'account', :action => 'login'
    end
  end

  def test_should_disable_site_admin
    login_as :quentin
    xhr :post, :admin, :id => users(:arthur).id
    assert_response :success
    assert !sites(:first).user(users(:arthur).id).site_admin?
  end

  def test_should_enable_site_admin
    sites(:first).user_with_deleted(3).update_attribute :deleted_at, nil
    login_as :quentin
    xhr :post, :admin, :id => users(:aaron).id
    assert_response :success
    assert sites(:first).user(users(:aaron).id).site_admin?
  end

  def test_should_disable_user
    login_as :quentin
    assert_no_difference User, :count_with_deleted do
      assert_difference User, :count, -1 do
        xhr :post, :destroy, :id => users(:quentin).id
        assert_response :success
      end
    end
    
    assert_equal users(:quentin), User.find_with_deleted(users(:quentin).id)
  end

  def test_should_enable_user
    login_as :quentin
    assert_no_difference User, :count_with_deleted do
      assert_difference User, :count do
        xhr :post, :enable, :id => 3
        assert_response :success
      end
    end
  end
end
