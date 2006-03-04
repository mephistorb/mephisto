require File.dirname(__FILE__) + '/../test_helper'
class ArticlesTest < ActionController::IntegrationTest
  fixtures :contents, :users, :sections, :assigned_sections, :sites

  def setup
    prepare_for_caching!
  end

  def test_should_expire_articles_after_editing
    visitor = visit
    writer  = login_as :quentin
    
    assert_caches_page contents(:welcome).full_permalink do
      visitor.read contents(:welcome)
    end

    assert_caches_page feed_url_for(:home) do
      visitor.syndicate sections(:home)
    end

    assert_expires_pages contents(:welcome).full_permalink, feed_url_for(:home) do
      writer.revise contents(:welcome), 'new welcome description'
    end
  end
end