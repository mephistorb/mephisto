require File.dirname(__FILE__) + '/../test_helper'
class ArticlesTest < ActionController::IntegrationTest
  fixtures :contents, :users, :sections, :assigned_sections

  def setup
    prepare_for_caching!
  end

  def test_should_expire_articles_after_editing
    visitor = open_visitor
    writer  = open_writer { |sess| sess.login_as :quentin }
    
    assert_caches_page contents(:welcome).full_permalink do
      visitor.read contents(:welcome)
    end

    assert_caches_page "/feed/#{sections(:home).to_feed_url * '/'}" do
      visitor.syndicate sections(:home)
    end

    assert_expires_pages contents(:welcome).full_permalink, "/feed/#{sections(:home).to_feed_url * '/'}" do
      writer.revise contents(:welcome), 'new welcome description'
    end
  end
end