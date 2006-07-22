ENV["RAILS_ENV"] = "test"
ENV['TZ'] = 'US/Central'
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

Time.class_eval do
  class << self
    alias_method :real_now, :now
  end

  def self.mock_now
    @current_time
  end

  def self.mock!(time)
    class << Time ; alias_method :now, :mock_now; end
    @current_time = time
    yield
    class << Time ; alias_method :now, :real_now; end
  end
end

class Test::Unit::TestCase
  include AuthenticatedTestHelper
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
  
  def host!(hostname)
    @request.host = hostname
  end

  def assert_difference(object, method = nil, difference = 1)
    initial_value = object.send(method)
    yield
    assert_equal initial_value + difference, object.send(method), "#{object}##{method}"
  end

  def assert_no_difference(object, method, &block)
    assert_difference object, method, 0, &block
  end

  def assert_event_created(mode)
    assert_difference Event, :count do
      event = yield
      assert_equal mode, event.mode
    end
  end

  def assert_event_created_for(article, mode)
    article = contents(article)
    assert_event_created mode do
      yield article
      article.events.first
    end
  end

  def assert_no_event_created
    assert_no_difference(Event, :count) { yield }
  end

  def assert_attachment_created(num = 1)
    assert_difference Attachment, :count, num do
      yield
    end
  end

  def assert_no_attachment_created
    assert_attachment_created 0 do
      yield
    end
  end

  def prepare_theme_fixtures
    %w(1 2).each do |i|
      FileUtils.rm_rf File.join(RAILS_ROOT, 'tmp/themes/site-' + i)
      FileUtils.cp_r File.join(RAILS_ROOT, 'test/fixtures/themes/site-' + i), File.join(RAILS_ROOT, 'tmp/themes/site-' + i)
    end
  end
end

class ActionController::IntegrationTest
  include Caboose::Caching::ReferencedCachingTestHelper
  
  # creates a session as a logged on user
  def login_as(login)
    visit do |sess|
      sess.login_as login
      yield sess if block_given?
    end
  end

  # creates an anonymous session
  def visit
    open_session do |sess|
      sess.extend Mephisto::Integration::Actor
      yield sess if block_given?
    end
  end

  def section_url_for(section)
    sections(section).to_url * '/'
  end

  def feed_url_for(section)
    "/feed/#{sections(section).to_feed_url * '/'}"
  end
end

class ActionController::Integration::Session
  def login_as(login)
    post '/account/login', :login => login, :password => login
    assert request.session[:user]
    assert cookies['user']
    assert redirect?
  end

  def get_with_basic(url, options = {})
    get url, nil, 'authorization' => "Basic #{Base64.encode64("#{options[:login]}:#{options[:login]}")}"
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