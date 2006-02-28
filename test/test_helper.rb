ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class Test::Unit::TestCase
  include AuthenticatedTestHelper
  include Caboose::Caching::ReferencedCachingTestHelper
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false

  # http://project.ioni.st/post/217#post-217
  #
  #  def test_new_publication
  #    assert_difference(Publication, :count) do
  #      post :create, :publication => {...}
  #      # ...
  #    end
  #  end
  # 
  def assert_difference(object, method = nil, difference = 1)
    initial_value = object.send(method)
    yield
    assert_equal initial_value + difference,
      object.send(method)
  end

  def assert_no_difference(object, method, &block)
    assert_difference object, method, 0, &block
  end

  def assert_attachment_created(num = 1)
    assert_difference Attachment, :count, num do
      assert_difference DbFile, :count, num do
        yield
      end
    end
  end

  def assert_no_attachment_created
    assert_attachment_created 0 do
      yield
    end
  end

  def file_upload(options = {})
    Technoweenie::FileUpload.new(options[:filename] || 'rails.png', options[:content_type] || 'image/png')
  end
end

class ActionController::IntegrationTest
  undef :assert_redirected_to rescue nil
  def login_as(user, session = @integration_session)
    session.login_as users(user).login, users(user).login
  end

  def get_and_login_as(user, url, session = @integration_session)
    session.get_and_login_as users(user).login, users(user).login, url
  end
end

class ActionController::Integration::Session
  def login_as(login, password)
    post '/account/login', :login => login, :password => password
    assert request.session[:user]
    assert cookies['user']
    assert redirect?
    follow_redirect!
  end

  def get_and_login_as(login, password, url)
    get url
    assert_redirected_to! '/account/login'
    login_as login, password
    assert_equal url, path
  end

  def assert_redirected_to(url)
    assert redirect?
    assert_equal url, interpret_uri(headers["location"].first)
  end

  def assert_redirected_to!(url)
    assert_redirected_to(url)
    follow_redirect!
  end
end