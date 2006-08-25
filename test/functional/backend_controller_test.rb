require File.dirname(__FILE__) + '/../test_helper'
require 'meta_weblog_api'
require 'movable_type_api'
require 'backend_controller'

# Re-raise errors caught by the controller.
class BackendController; def rescue_action(e) raise e end; end

class BackendControllerTest < Test::Unit::TestCase
  fixtures :users, :sections, :assigned_sections, :contents, :sites
  
  def setup
    @controller = BackendController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @protocol   = :xmlrpc
  end

  def test_meta_weblog_get_categories
    args = [ 1, 'quentin', 'quentin' ]

    result = invoke_layered :metaWeblog, :getCategories, *args
    assert_equal 'Home', result.first
  end

  def test_meta_weblog_get_post
    args = [ 1, 'quentin', 'quentin' ]

    result = invoke_layered :metaWeblog, :getPost, *args
    assert_equal 'Welcome to Mephisto', result['title'], result.inspect
  end

  def test_meta_weblog_get_recent_posts
    args = [ 1, 'quentin', 'quentin', 2 ]

    articles = invoke_layered :metaWeblog, :getRecentPosts, *args
    assert_equal %w(test-draft article-in-the-future), articles.collect { |a| a['permaLink'] }, articles.inspect
  end

  def test_meta_weblog_delete_post
    args = [ 1, 1, 'quentin', 'quentin', 1 ]

    assert_difference Article, :count, -1 do
      result = invoke_layered :metaWeblog, :deletePost, *args
    end
  end

  def test_meta_weblog_edit_post
    post_time            = Time.now.midnight.utc
    article              = contents(:welcome)
    article.title        = "Modified!"
    article.body         = "this is a *test*"
    article.excerpt      = "* one\n* two\n"
    article.published_at = post_time

    struct = MetaWeblogService.new(@controller).article_dto_from(article)
    invoke_layered :metaWeblog, :editPost, contents(:welcome).id, 'quentin', 'quentin', struct, 1

    assert_equal post_time.to_s(:db), struct['dateCreated']

    assert_equal 'Modified!', article.reload.title
    assert_equal "<p>this is a <strong>test</strong></p>", article.body_html, article.inspect
    assert_equal "<ul>\n\t<li>one</li>\n\t\t<li>two</li>\n\t</ul>", article.excerpt_html, article.inspect
    assert_equal post_time, article.published_at
    assert_equal users(:quentin), article.updater
  end

  def test_meta_weblog_new_post
    assert_difference Article, :count do
      article = Article.new
      article.title = "Posted via Test"
      article.body = "body"
      article.excerpt = "extend me"
      article.published_at = Time.now.midnight.utc

      args = [ 1, 'quentin', 'quentin', MetaWeblogService.new(@controller).article_dto_from(article), 1 ]

      result = invoke_layered :metaWeblog, :newPost, *args
      assert result
      new_post = Article.find(result)
      
      assert_equal "Posted via Test", new_post.title
      assert_equal article.body, new_post.body
      assert_equal "<p>body</p>", new_post.body_html
      assert_equal "<p>extend me</p>", new_post.excerpt_html
    end
  end

  # def test_meta_weblog_new_media_object
  #   media_object = MetaWeblogStructs::MediaObject.new(
  #     "name" => Digest::SHA1.hexdigest("upload-test--#{Time.now}--") + ".jpg",
  #     "type" => "image/jpeg",
  #     "bits" => Base64.encode64(File.open(File.expand_path(RAILS_ROOT) + "/public/images/shadow.png", "rb") { |f| f.read })
  #   )
  # 
  #   args = [ 1, 'quentin', 'quentin', media_object ]
  # 
  #   result = invoke_layered :metaWeblog, :newMediaObject, *args
  #   assert result['url'] =~ /#{media_object['name']}/
  #   assert File.unlink(File.expand_path(RAILS_ROOT) + "/public/images/#{media_object['name']}")
  # end

  def test_should_show_filters
    result  = invoke_layered :mt, :supportedTextFilters
    filters = %w(textile_filter markdown_filter smartypants_filter)
    result.each { |f| filters.include? f[:key] }
  end

  def test_meta_weblog_fail_authentication
    args = [ 1, 'quentin', 'using a wrong password', 2 ]
    # This will be a little more useful with the upstream changes in [1093]
    assert_raise(XMLRPC::FaultException) { invoke_layered :metaWeblog, :getRecentPosts, *args }
  end
end
