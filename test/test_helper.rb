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
  def open_writer
    open_session do |sess|
      sess.extend Mephisto::Actors::Writer
      yield sess if block_given?
    end
  end

  def open_visitor
    open_session do |sess|
      sess.extend Mephisto::Actors::Visitor
      yield sess if block_given?
    end
  end

  # Prepares a caching directory for use.  Put this in your test case's #setup method.
  def prepare_for_caching!
    dir = File.join(RAILS_ROOT, 'test/cache')
    ActionController::Base.page_cache_directory = dir
    FileUtils.rm_rf dir rescue nil
    FileUtils.mkdir_p dir
  end

  def assert_caches_pages(*urls)
    yield if block_given?
    urls.map { |url| assert_page_cached url }
  end

  def assert_expires_pages(*urls)
    yield if block_given?
    urls.map { |url| assert_not_cached url }
  end

  # Asserts a page was cached.
  def assert_cached(url)
    assert page_cache_exists?(url), "#{url} is not cached"
  end

  # Asserts a page was not cached.
  def assert_not_cached(url)
    assert !page_cache_exists?(url), "#{url} is cached"
  end

  alias assert_caches_page  assert_caches_pages
  alias assert_expires_page assert_expires_pages

  private
    # Gets the page cache filename given a relative URL like /blah
    def page_cache_file(url)
      ActionController::Base.send :page_cache_file, url
    end

    # Gets a test page cache filename given a relative URL like /blah
    def page_cache_test_file(url)
      File.join ActionController::Base.page_cache_directory, page_cache_file(url)[1..-1]
    end

    # Returns true/false whether the page cache file exists.
    def page_cache_exists?(url)
      File.exists? page_cache_test_file(url)
    end
end

class ActionController::Integration::Session
  def login_as(login)
    post '/account/login', :login => login, :password => login
    assert request.session[:user]
    assert cookies['user']
    assert redirect?
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

module Mephisto::Actors
  module Visitor
    def read(article)
      get article.full_permalink
      assert_equal 200, status
    end

    def syndicate(section)
      get "/feed/#{section.to_feed_url * '/'}"
      assert_equal 200, status
    end
  end

  module Writer
    def revise(article, contents)
      post "/admin/articles/update/#{article.id}", 'article[body]' => contents, 'article_published' => '1'
      assert_redirected_to "/admin/articles/index"
    end
  end
end