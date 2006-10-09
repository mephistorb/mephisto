ENV["RAILS_ENV"] = "test"
ENV['TZ'] = 'US/Central'

require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'
require File.expand_path(File.dirname(__FILE__) + "/actor")
ASSET_PATH = File.join(RAILS_ROOT, 'test/fixtures/tmp/assets') unless Object.const_defined?(:ASSET_PATH)
require File.join(File.dirname(__FILE__), 'referenced_caching_test_helper')

Site.cache_sweeper_tracing = true
ActiveRecord::Base.instantiate_observers

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

# TRUNCATE table to reset the id autonumber
# needed for the asset tests
# may have to rethink this...
Fixtures.class_eval do
  case ActiveRecord::Base.connection
    when ActiveRecord::ConnectionAdapters::MysqlAdapter
      def delete_existing_fixtures
        self.class.delete_existing_fixtures_for @connection, @table_name
      end
      
      def self.delete_existing_fixtures_for(connection, table_name)
        connection.delete  "TRUNCATE TABLE #{table_name}", 'Fixture Delete'
        connection.execute "ALTER TABLE #{table_name} AUTO_INCREMENT = 1", 'Renumber Auto Increment'
      end
    when ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
      def delete_existing_fixtures
        self.class.delete_existing_fixtures_for @connection, @table_name
      end
      
      def self.delete_existing_fixtures_for(connection, table_name)
        connection.delete  "TRUNCATE TABLE #{table_name}", 'Fixture Delete'
        connection.execute "SELECT setval('public.#{table_name}_id_seq', 1, false)", 'Renumber Auto Increment'
      end
    else # tests will fail because they cant find Asset.find(1) then
      def self.delete_existing_fixtures_for(connection, table_name)
        connection.delete  "DELETE FROM #{table_name}", 'Fixture Delete'
      end
  end
end

THEME_ROOT = RAILS_PATH + 'tmp/themes' unless Object.const_defined?(:THEME_ROOT)
THEME_FILES = [
  'about.yml',
  'preview.png',
  'images',
  'javascripts/behavior.js',
  'layouts/layout.liquid',
  'stylesheets/style.css',
  'templates/archive.liquid',
  'templates/author.liquid',
  'templates/error.liquid',
  'templates/home.liquid',
  'templates/index.liquid',
  'templates/page.liquid',
  'templates/search.liquid',
  'templates/section.liquid',
  'templates/single.liquid'
] unless Object.const_defined?(:THEME_FILES)

Mephisto::Routing.redirections.clear
Mephisto::Routing.deny 'limited_deny'
Mephisto::Routing.deny 'deny/foo/*'
Mephisto::Routing.deny 'deny/bar/?/?'
Mephisto::Routing.redirect \
  'redirect/from/*'           => 'to/here',
  'redirect/match/wildcard/*' => 'this/$1',
  'redirect/match/vars/?/?'   => 'this/$2/$1',
  '/sanitize/path'            => 'foo://bar',
  'redirect/external'         => 'http://external/$1/$2'

class Test::Unit::TestCase
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false

  def host!(hostname)
    @request.host = hostname
  end

  def liquid(key = nil)
    assigns = @controller.instance_variable_get(:@liquid_assigns)
    key ? assigns[key.to_s] : assigns
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

  def assert_file_exists(file, message = nil)
    message ||= "File not found: #{file}"
    assert File.file?(file), message
  end

  def get_xpath(xpath)
    if @rexml.nil?
      @rexml = REXML::Document.new(@response.body)
      assert @rexml
    end
 
    REXML::XPath.match(@rexml, xpath)
  end
 
  def assert_xpath(xpath, msg=nil)
    assert !(get_xpath(xpath).empty?), "XPath '#{xpath}' was not matched: #{msg}"
  end
 
  def assert_not_xpath(xpath, msg=nil)
    assert get_xpath(xpath).empty?, "XPath '#{xpath}' was matched: #{msg}"
  end

  def assert_atom_entries_size(entries)
    assert_equal 1, get_xpath(%{/feed[@xmlns="http://www.w3.org/2005/Atom" and count(child::entry)=#{entries}]}).size, "Atom 1.0 feed has wrong number of feed/entry nodes"
  end

  # Sets the current user in the session from the user fixtures.
  def login_as(user, site = nil)
    user = user ? users(user) : nil
    site = sites(site || :first)
    host! site.host
    @request.session[:user] = user ? User.authenticate_for(site, user.login, user.login) : nil
    if block_given?
      yield
      reset!
    end
  end

  def content_type(type)
    @request.env['Content-Type'] = type
  end

  def accept(accept)
    @request.env["HTTP_ACCEPT"] = accept
  end

  def authorize_as(user)
    if user
      @request.env["HTTP_AUTHORIZATION"] = "Basic #{Base64.encode64("#{users(user).login}:test")}"
      accept       'application/xml'
      content_type 'application/xml'
    else
      @request.env["HTTP_AUTHORIZATION"] = nil
      accept       nil
      content_type nil
    end
    if block_given?
      yield
      reset!
    end
  end

  def assert_difference(object, method = nil, difference = 1)
    initial_value = object.send(method)
    yield
    assert_equal initial_value + difference, object.send(method), "#{object}##{method}"
  end

  def assert_no_difference(object, method, &block)
    assert_difference object, method, 0, &block
  end

  def login_with_cookie_as(user)
    @request.cookies['user'] = user ? CGI::Cookie.new( 
      'name'    => 'user',
      'value'   => users(user).activation_code,
      'expires' => 2.weeks.from_now,
      'path'    => '/',
      'domain'  => 'example.com'
    ) : nil
  end
  
  # mocks a Liquid::Context
  def mock_context(assigns = {}, registers = {})
    t = Liquid::Template.new
    t.assigns.update assigns
    t.registers.update registers
    Liquid::Context.new t
  end

  # Assert the block redirects to the login
  # 
  #   assert_requires_login(:bob) { |c| c.get :edit, :id => 1 }
  #
  def assert_requires_login(login = nil)
    yield HttpLoginProxy.new(self, login)
  end

  def assert_http_authentication_required(login = nil)
    yield XmlLoginProxy.new(self, login)
  end

  def reset!(*instance_vars)
    instance_vars = [:controller, :request, :response] unless instance_vars.any?
    instance_vars.collect! { |v| "@#{v}".to_sym }
    instance_vars.each do |var|
      instance_variable_set(var, instance_variable_get(var).class.new)
    end
  end

  def prepare_theme_fixtures
    FileUtils.rm_rf THEME_ROOT
    FileUtils.mkdir_p THEME_ROOT
    %w(1 2).each do |i|
      FileUtils.cp_r File.join(RAILS_ROOT, 'test/fixtures/themes/site-' + i), File.join(THEME_ROOT, 'site-' + i)
    end
  end

  def assert_models_equal(expected_models, actual_models, message = nil)
    to_test_param = lambda { |r| "<#{r.class}:#{r.to_param}>" }
    full_message = build_message(message, "<?> expected but was\n<?>.\n", 
      expected_models.collect(&to_test_param), actual_models.collect(&to_test_param))
    assert_block(full_message) { expected_models == actual_models }
  end
end

class ActionController::IntegrationTest
  include Mephisto::Caching::ReferencedCachingTestHelper
  
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

  def section_url_for(section, article = nil)
    (article ? sections(section).to_page_url(contents(article)) : sections(section).to_url) * '/'
  end

  def feed_url_for(section)
    "/feed/#{sections(section).to_feed_url * '/'}"
  end
end

class ActionController::Integration::Session
  def login_as(login)
    post '/account/login', :login => login, :password => login
    assert request.session[:user]
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

class BaseLoginProxy
  attr_reader :controller
  attr_reader :options
  def initialize(controller, login)
    @controller = controller
    @login      = login
  end

  private
    def authenticated
      raise NotImplementedError
    end
    
    def check
      raise NotImplementedError
    end
    
    def method_missing(method, *args)
      @controller.reset!
      authenticate
      @controller.send(method, *args)
      check
    end
end

class HttpLoginProxy < BaseLoginProxy
  protected
    def authenticate
      @controller.login_as @login if @login
    end
    
    def check
      @controller.assert_redirected_to :controller => 'sessions', :action => 'new'
    end
end

class XmlLoginProxy < BaseLoginProxy
  protected
    def authenticate
      @controller.accept 'application/xml'
      @controller.authorize_as @login if @login
    end
    
    def check
      @controller.assert_response 401
    end
end