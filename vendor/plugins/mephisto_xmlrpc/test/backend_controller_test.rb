require File.dirname(__FILE__) + '/../../../../test/test_helper'
require 'action_web_service/test_invoke'
require 'meta_weblog_api'
require 'movable_type_api'
require 'backend_controller'

# Re-raise errors caught by the controller.
class BackendController; def rescue_action(e) raise e end; end

class BackendControllerTest < Test::Unit::TestCase
  fixtures :users, :sections, :assigned_sections, :contents, :sites, :assets

  def setup
    @controller = BackendController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @protocol   = :xmlrpc
    FileUtils.mkdir_p ASSET_PATH
  end

  def teardown
    FileUtils.rm_rf ASSET_PATH
  end

  # Movable Type Backend Api Tests
  def test_movable_type_get_category_list
    # test test_movable_type_get_category_list
    args = [ 1, 'quentin', 'test' ]

    result = invoke_layered :mt, :getCategoryList, *args
    assert_equal 'Home', result.first['categoryName']
  end

  def test_movable_type_get_post_categories
    # test test_movable_type_get_post_categories
    args = [ 1, 'quentin', 'test' ]

    result = invoke_layered :mt, :getPostCategories, *args
    assert_equal %w(About Home), result.collect { |c| c['categoryName'] }
  end

  def test_movable_type_set_post_categories
    # test test_movable_type_set_post_categories
    # this needs some work!! FIXME FIXME FIXME

    c1 = MovableTypeStructs::PostCategory.new(:categoryId => 1, :categoryName => 'Home', :isPrimary => false)
    c2 = MovableTypeStructs::PostCategory.new(:categoryId => 2, :categoryName => 'About', :isPrimary => false)
    c3 = MovableTypeStructs::PostCategory.new(:categoryId => 9, :categoryName => 'Links', :isPrimary => false)

    args = [ 1, 'quentin', 'test', [ c1, c2, c3 ]]

    result = invoke_layered :mt, :setPostCategories, *args
    assert_equal true, result

    # see if the categories have been set
    args = [ 1, 'quentin', 'test' ]

    result = invoke_layered :mt, :getPostCategories, *args
    assert_equal ["1","2","9"], result.collect { |c| c['categoryId'] }.sort

    # set the categories back to the default
    args = [ 1, 'quentin', 'test', [c1,c2] ]

    result = invoke_layered :mt, :setPostCategories, *args
    assert_equal true, result
  end

  def test_movable_type_supported_methods
    # test test_movable_type_supported_methods
    result = invoke_layered :mt, :supportedMethods

    assert_instance_of Array, result
  end

  def test_movable_type_supported_text_filters
    # test test_movable_type_supported_text_filters
    result = invoke_layered :mt, :supportedTextFilters

    assert_instance_of Array, result
  end



  def test_meta_weblog_get_categories
    args = [ 1, 'quentin', 'test' ]

    result = invoke_layered :metaWeblog, :getCategories, *args
    assert_equal 'Home', result.first
  end

  def test_meta_weblog_get_post
    args = [ 1, 'quentin', 'test' ]

    result = invoke_layered :metaWeblog, :getPost, *args
    assert_equal 'Welcome to Mephisto', result['title'], result.inspect
    assert_equal %w(About Home), result['categories']
  end

  def test_meta_weblog_get_recent_posts
    args = [ 1, 'quentin', 'test', 2 ]

    articles = invoke_layered :metaWeblog, :getRecentPosts, *args
    assert_equal %w(test-draft article-in-the-future), articles.collect { |a| a['permaLink'] }, articles.inspect
  end

  def test_meta_weblog_delete_post
    args = [ 1, 1, 'quentin', 'test', 1 ]

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
    invoke_layered :metaWeblog, :editPost, contents(:welcome).id, 'quentin', 'test', struct, true

    assert_equal post_time, struct['dateCreated']

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

      args = [ 1, 'quentin', 'test', MetaWeblogService.new(@controller).article_dto_from(article), 1 ]

      result = invoke_layered :metaWeblog, :newPost, *args
      assert result
      new_post = Article.find(result)

      assert_equal "Posted via Test", new_post.title
      assert_equal article.body, new_post.body
      assert_equal "<p>body</p>", new_post.body_html
      assert_equal "<p>extend me</p>", new_post.excerpt_html
    end
  end

  def test_meta_weblog_new_post_tags
    # test weather we can create a new post, set tags and get away with it...
    tags = 'blog, emacs, fun, rails, ruby'
    article = MetaWeblogStructs::Article.new(:title => 'This is a title', :description => 'This is a post', :mt_keywords => tags)

    args = [ 1, 'quentin', 'test', article, 1 ]

    result = invoke_layered :metaWeblog, :newPost, *args
    # assert result
    new_post = Article.find(result)
    assert_equal Tag.parse_to_tags(tags).collect(&:name).sort, new_post.tags.collect(&:name).sort
  end

  def test_meta_weblog_edit_post_tags
    # changing tags
    tags = 'blog, emacs, fun, rails, ruby'
    article = MetaWeblogStructs::Article.new(:title => 'This is a title', :description => 'This is a post', :mt_keywords => tags)
    args = [ 1, 'quentin', 'test', article, 1 ]
    post_id = invoke_layered :metaWeblog, :newPost, *args

    new_post = Article.find(post_id)
    assert_equal Tag.parse_to_tags(tags).collect(&:name).sort, new_post.tags.collect(&:name).sort

    tags = 'bar, baz, foo'
    article = MetaWeblogStructs::Article.new(:title => 'This is a title', :description => 'This is a post', :mt_keywords => tags)
    args = [ post_id, 'quentin', 'test', article, 1]
    edit_result = invoke_layered :metaWeblog, :editPost, *args
    assert_equal true, edit_result

    new_post = Article.find(post_id)
    assert_equal Tag.parse_to_tags(tags).collect(&:name).sort, new_post.tags.collect(&:name).sort
  end

  def test_meta_weblog_get_post_with_tags
    # set tags and see if we recive them!
    tags = 'blog, emacs, fun, rails, ruby'
    article = MetaWeblogStructs::Article.new(:title => 'This is a title', :description => 'This is a post', :mt_keywords => tags)

    args = [ 1, 'quentin', 'test', article, 1 ]
    post_id = invoke_layered :metaWeblog, :newPost, *args

    args = [ post_id, 'quentin', 'test' ]
    result = invoke_layered :metaWeblog, :getPost, *args

    assert_equal tags, result['mt_keywords']
  end


  def test_meta_weblog_new_post_min
    # This is going to test weather a post is correctly submited or not without the published_at field!
    # See http://www.xmlrpc.com/metaWeblogApi#theStruct or
    # See http://www.sixapart.com/developers/xmlrpc/metaweblog_api/metaweblognewpost.html for more information
    assert_difference Article, :count do
      article = Article.new
      article.title = 'This is a title'
      article.body = 'This is a post'

      args = [ 1, 'quentin', 'test', MetaWeblogService.new(@controller).article_dto_from(article), 1 ]

      result = invoke_layered :metaWeblog, :newPost, *args
      assert result
      new_post = Article.find(result)

      assert_equal 'This is a post', new_post.body
      assert_equal '<p>This is a post</p>', new_post.body_html
      assert_equal 'This is a title', new_post.title
      assert_equal :published, new_post.status
    end
  end

  def test_meta_weblog_new_post_publish
    # Test weather publish is set correctly on 1 and true to :published otherwise :pending
    [{ :set => 1,     :expect => :published },
     { :set => 0,     :expect => :pending },
     { :set => true,  :expect => :published},
     { :set => false, :expect => :pending }].each do |c|
      assert_difference Article, :count do
        article = Article.new
        article.title = 'This is a title'
        article.body = 'This is a post'

        args = [ 1, 'quentin', 'test', MetaWeblogService.new(@controller).article_dto_from(article), c[:set] ]

        result = invoke_layered :metaWeblog, :newPost, *args
        assert result
        new_post = Article.find(result)

        assert_equal 'This is a post', new_post.body
        assert_equal '<p>This is a post</p>', new_post.body_html
        assert_equal 'This is a title', new_post.title
        assert_equal c[:expect], new_post.status
      end
    end
  end

  def test_should_upload_file_via_meta_weblog_new_media_object
    now = Time.now.utc
    media_object = new_media_object

    args = [ 1, 'quentin', 'test', media_object ]
    result = invoke_layered :metaWeblog, :newMediaObject, *args
    assert result['url'] =~ /#{media_object['name']}$/

    assert_file_exists File.join(ASSET_PATH, now.year.to_s, now.month.to_s, now.day.to_s, media_object['name'])
  end

  def test_should_guess_content_type_for_gif
    media_object = new_media_object 'type' => nil, :name => 'filename.gif'
    assert_nil media_object['type']

    args = [ 1, 'quentin', 'test', media_object ]
    result = invoke_layered :metaWeblog, :newMediaObject, *args

    new_asset = Asset.find :first, :order => 'created_at DESC'
    assert_equal 'image/gif', new_asset.content_type
  end

  def test_should_guess_content_type
    svc = MetaWeblogService.new nil
    {'foo.png' => 'image/png', 'foo.jpg' => 'image/jpeg', 'foo.gif' => 'image/gif'}.each do |filename, expected|
      assert_equal expected, svc.send(:guess_content_type_from, filename)
    end
  end

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

  protected
    def new_media_object(options = {})
      MetaWeblogStructs::MediaObject.new(options.reverse_merge!(
        'name' => Digest::SHA1.hexdigest("upload-test--#{Time.now}--") + ".png",
        'type' => 'image/png',
        'bits' => Base64.encode64(File.read(File.expand_path(RAILS_ROOT) + '/public/images/mephisto/shadow.png'))
      ))
    end
end
