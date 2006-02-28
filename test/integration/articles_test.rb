require File.dirname(__FILE__) + '/../test_helper'
class ArticlesTest < ActionController::IntegrationTest
  fixtures :contents, :sections, :assigned_sections, :users

  def setup
    reset!
  end

  def test_should_login_and_post_and_publish_article
    #visitor = open_session do |sess|
    #  sess.get article_url(assigns(:article).hash_for_permalink)
    #  assert_equal 500, sess.status
    #end

    get_and_login_as :quentin, '/admin/articles/index'

    get '/admin/articles/new'
    
    assert_difference Article, :count do
      #post '/admin/articles/create', :article => { :title => "My Red Hot Car", :excerpt => "Blah Blah", :body => "Blah Blah" }
      post '/admin/articles/create', 'article[title]' => "My Red Hot Car", 'article[excerpt]' => "Blah Blah", 'article[body]' => "Blah Blah"
    end

    article = assigns(:article)
    assert !article.published?
    assert_redirected_to! '/admin/articles'

    get "/admin/articles/edit/#{article.id}"

    post "/admin/articles/update/#{article.id}", 'article[section_ids][]' => sections(:home).id, :article_published => '1', 
      'article[published_at(1i)]' => '2006', 'article[published_at(2i)]' => '2', 'article[published_at(3i)]' => '25',
      'article[published_at(4i)]' => '00',   'article[published_at(5i)]' => '00'
    assert_redirected_to '/admin/articles/index'

    assert assigns(:article).published?

    #visitor.get article_url(assigns(:article).hash_for_permalink)
    #assert_equal 200, visitor.status
  end
end