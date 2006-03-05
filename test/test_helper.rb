ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class Test::Unit::TestCase
  include AuthenticatedTestHelper
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false

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
  include Caboose::Caching::ReferencedCachingTestHelper
  
  # creates a session as a logged on user
  def login_as(login)
    visit do |sess|
      sess.login_as login
    end
  end

  # creates an anonymous session
  def visit
    open_session do |sess|
      sess.extend Mephisto::Actor
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

module Mephisto::Actor
  def read(record = nil)
    url = case record
      when Article then record.full_permalink
      when Section then record.to_url * '/'
      else record.to_s
    end
    get url
    assert_equal 200, status
  end

  def syndicate(section)
    get "/feed/#{section.to_feed_url * '/'}"
    assert_equal 200, status
  end

  def revise(article, contents)
    post "/admin/articles/update/#{article.id}", to_article_params(article, contents.is_a?(Hash) ? contents : {:body => contents})
    assert_redirected_to "/admin/articles/index"
  end

  def create(params)
    post '/admin/articles/create', to_article_params(params)
    assert_redirected_to "/admin/articles"
  end

  private
    def to_article_params(*args)
      options = args.pop
      article = args.first
      if article
        options[:published_at] ||= article.published_at
        options[:sections]     ||= article.sections
        [:title, :excerpt, :body].each { |key| options[key] ||= article.send(key) }
      end

      params = [:title, :excerpt, :body].inject({}) { |params, key| params.merge "article[#{key}]" => options[key] }
      params['article_published'] = options[:published_at] ? '1' : '0'
      add_published_at! params, options[:published_at] if options[:published_at].is_a?(Time)
      params = params.keys.inject([]) { |all, k| params[k] ? all << "#{k}=#{CGI::escape params[k]}" : all } # change to an array so we can add multiple sections
      add_section_ids! params, options[:sections]
      params * '&'
    end

    def add_published_at!(params, date)
      params.update to_date_params(:article, :published_at, date)
    end

    def add_section_ids!(params, sections)
      (sections || []).each { |s| params << "article[section_ids][]=#{s.id}" }
    end

    def to_date_params(object, method, date)
      {
        "#{object}[#{method}(1i)]" => date.year.to_s,
        "#{object}[#{method}(2i)]" => date.month.to_s,
        "#{object}[#{method}(3i)]" => date.day.to_s,
        "#{object}[#{method}(4i)]" => date.hour.to_s,
        "#{object}[#{method}(5i)]" => date.min.to_s
      }
    end
end