require File.dirname(__FILE__) + '/../test_helper'

class CommentDropTest < Test::Unit::TestCase
  fixtures :contents, :sites
  
  def setup
    @comment = contents(:welcome_comment).to_liquid
    @mock_comment = [:published_at, :created_at, :author, :author_email, :author_ip, :title, :approved?].inject({:body_html => 'foo'}) { |h, i| h.update i => true }
  end
  
  def test_should_convert_comment_to_drop
    assert_kind_of Liquid::Drop, contents(:welcome_comment).to_liquid
  end
  
  def test_should_output_author_name_only_if_no_url
    assert_equal '<span>rico</span>', @comment.author_link
  end
  
  def test_should_output_author_link_if_url_given
    @comment.source.author_url = 'http://test'
    assert_equal '<a href="http://test">rico</a>', @comment.author_link
  end

  def test_should_check_for_existance_of_author_url
    @comment.source.author_url = nil
    assert_nil @comment.author_url
    @comment.source.author_url = ''
    assert_nil @comment.author_url
  end

  def test_should_return_correct_author_link
    assert_equal '<span>rico</span>',                @comment.author_link
    @comment.source.author_url = 'abc'
    assert_equal %Q{<a href="http://abc">rico</a>},  @comment.author_link
    @comment.source.author_url = 'https://abc'
    assert_equal %Q{<a href="https://abc">rico</a>}, @comment.author_link
    @comment.source.author     = '<strong>rico</strong>'
    @comment.source.author_url = '<strong>https://abc</strong>'
    assert_equal %Q{<a href="http://&lt;strong&gt;https://abc&lt;/strong&gt;">&lt;strong&gt;rico&lt;/strong&gt;</a>}, @comment.author_link
  end
  
  def test_should_show_filtered_text
    comment  = contents(:welcome).comments.create :body => '*test* comment', :author => 'bob', :author_ip => '127.0.0.1', :filter => 'textile_filter'
    assert_valid comment
    assert_equal 'textile_filter', comment.filter
    liquid   = comment.to_liquid
    assert_equal '<p><strong>test</strong> comment</p>', liquid.before_method(:body)
  end
  
  def test_comment_url
    t = Time.now.utc - 3.days
    assert_equal "/#{t.year}/#{t.month}/#{t.day}/welcome-to-mephisto", @comment.url
  end
  
  def test_should_return_correct_presentation_class_for_article_author
    @comment = CommentDrop.new(create_comment_stub(:user_id => 5, :article => stub(:user_id => 5)))
    assert_equal 'by-author', @comment.presentation_class
  end
  
  def test_should_return_correct_presentation_class_for_guest
    @comment = CommentDrop.new(create_comment_stub(:user_id => nil, :article => stub(:user_id => 5)))
    assert_equal 'by-guest', @comment.presentation_class
  end
  
  def test_should_return_correct_presentation_class_for_user
    @comment = CommentDrop.new(create_comment_stub(:user_id => 3, :article => stub(:user_id => 5)))
    assert_equal 'by-user', @comment.presentation_class
  end
  
  private
    def create_comment_stub(options)
      returning stub(@mock_comment.merge(options)) do |stub|
        def stub.id() 55; end
      end
    end
end