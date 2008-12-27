ENV["RAILS_ENV"] = "test"
ENV['TZ'] = 'US/Central'

require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'
require 'webrat/rails'
require 'ruby-debug'
require 'machinist'
require File.join(File.dirname(__FILE__), '..', 'spec', 'blueprints')
require File.expand_path(File.dirname(__FILE__) + "/actor")
ASSET_PATH = File.join(RAILS_ROOT, 'test/fixtures/tmp/assets') unless Object.const_defined?(:ASSET_PATH)
require File.join(File.dirname(__FILE__), 'referenced_caching_test_helper')

Site.cache_sweeper_tracing = true
ActiveRecord::Base.instantiate_observers

Webrat.configure do |config|
  config.mode = :rails
end

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

  def self.has_image_processor?
    @has_image_processor ||= Object.const_defined?(:ImageScience) || Object.const_defined?(:Magick)
  end
  
  def has_image_processor?
    self.class.has_image_processor?
  end

  def use_temp_file(path)
    temp_path = File.join(ASSET_PATH, File.basename(path))
    FileUtils.cp path, temp_path
    yield temp_path
  end

  def assert_template_result(expected, template, assigns={}, message=nil)
    assert_equal expected, Liquid::Template.parse(template).render(assigns)
  end 

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
    assert_equal 1, get_xpath(%{/feed[count(child::entry)=#{entries}]}).size, "Atom 1.0 feed has wrong number of feed/entry nodes"
  end

  # Sets the current user in the session from the user fixtures.
  def login_as(user, site = nil)
    user = user ? users(user) : nil
    site = sites(site || :first)
    host! site.host
    @request.session[:user] = user ? User.authenticate_for(site, user.login, 'test') : nil
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
      'domain'  => 'test.host'
    ) : nil
  end
  
  # mocks a Liquid::Context
  def mock_context(assigns = {}, registers = {})
    returning Liquid::Context.new(assigns, registers) do |context|
      assigns.keys.each { |k| context[k].context = context }
    end
  end

  def liquify(*records, &block)
    BaseDrop.liquify(@context, *records, &block)
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

# The plugin tests appear to be written against an old version of the
# plugin API, and not against Sven's new engine-based API.  We want to
# update these tests in the future.
#module Mephisto
#  module Plugins
#    class PluginWhammyJammy < Mephisto::Plugin
#      option :foo, 'one'
#      option :bar, 2
#      option :baz, [3]
#    end
#    
#    class FooBar < Mephisto::Plugin
#    end
#    
#    class NonPlugin
#    end
#  end
#end

begin
  require 'ruby-debug'
  Debugger.start
rescue LoadError
end
