require File.dirname(__FILE__) + '/../../test_helper'

# Re-raise errors caught by the controller.
class Admin::OverviewController; def rescue_action(e) raise e end; end

class Admin::OverviewControllerTest < ActionController::TestCase
  def setup
    Site.transaction do
      [Site, User, Event, Article, Membership].each &:delete_all
    end
    @site   = Site.make
    host! @site.host
  end

  def test_routing
    with_options :controller => 'admin/overview' do |test|
      test.assert_routing 'admin',     :action => 'index'
      test.assert_routing 'admin/overview.xml', :action => 'feed'
    end
  end

  def test_should_allow_site_admins_to_access_site
    @user = User.make
    Membership.make :user => @user, :site => @site, :admin => true
    @request.session[:user] = User.authenticate_for(@site, @user.login, 'password')

    get :index
    assert_response :success
  end

  def test_should_allow_site_members_to_acces_overview
    @user = User.make
    Membership.make :user => @user, :site => @site, :admin => false
    @request.session[:user] = User.authenticate_for(@site, @user.login, 'password')

    get :index
    assert_response :success
  end
  
  def test_should_require_http_auth_on_feed
    get :feed
    assert_response 401
  end
  
  def test_should_allow_http_auth_on_feed
    @user = User.make
    Membership.make :user => @user, :site => @site, :admin => true
    @request.env['HTTP_AUTHORIZATION'] = "Basic #{Base64.encode64("#{@user.login}:password")}"
    get :feed
    assert_response :success
  end
  
  def test_should_sort_future_items_in_todays_events
    Site.transaction do
      @admin   = User.make
      @user    = User.make
      @article = Article.make :site => @site, :user => @user
      @article.title = 'foo' ; @article.body = 'bar'
      @event1  = Event.make_from @article
      @comment = Comment.make :article => @article
      @event2  = Event.make_from @comment
      @article.title = 'foo2' ; @article.body = 'bar2'
      @event3  = Event.make_from @article
      @events  = Event.all
      assert_equal 3, @events.size
      
      today = Time.now.utc
      assert @event1.update_attribute(:created_at, today + 2.days)
      assert @event2.update_attribute(:created_at, today)
      assert @event3.update_attribute(:created_at, today - 1.day)
      
      Membership.make :user => @admin, :site => @site, :admin => true
    end

    @request.session[:user] = User.authenticate_for(@site, @admin.login, 'password')
    get :index
    assert assigns(:todays_events).include?(@event1),    "#{assigns(:todays_events).collect(&:id).inspect}"
    assert assigns(:todays_events).include?(@event2),  "#{assigns(:todays_events).collect(&:id).inspect}"
    assert assigns(:yesterdays_events).include?(@event3), "#{assigns(:yesterdays_events).collect(&:id).inspect}"
  end
end
