require File.dirname(__FILE__) + '/test_helper'
require 'ostruct'

require 'convert/typo'
class TypoImporterTest < Test::Unit::TestCase
  fixtures :sites, :sections, :contents, :users

  def test_should_import_users
    typo_user = OpenStruct.new(:email => 'foo@email.com', :login => 'foo')
    user      = Typo.import_user(typo_user)
    [:email, :login].each do |attr|
      assert_equal typo_user.send(attr), user.send(attr)
    end
    assert_equal user, User.authenticate(typo_user.login, Typo.new_user_password)
    assert_equal 'textile_filter', user.filter
  end
  
  def test_should_create_sections
    fake_article1 = OpenStruct.new('categories' => [
        OpenStruct.new(:name => 'foo'),
      ]
    )
    fake_article2 = OpenStruct.new('categories' => [
        OpenStruct.new(:name => 'foo'),
        OpenStruct.new(:name => 'bar')
      ]
    )
    
    assert_difference Section, :count do
      Typo.find_or_create_sections(fake_article1)
    end
    
    assert_difference Section, :count do
      Typo.find_or_create_sections(fake_article2)
    end
  end
  
  def test_should_create_article
    # need to import our fake users first
    Typo.import_users
    typo_article = OpenStruct.new :title => 'typo article', :body => 'excerpt', :extended => 'body', :categories => [], :user_id => 1
    assert_difference Article, :count do
      article = Typo.create_article(sites(:first), typo_article)
      assert_equal typo_article.body, article.excerpt
      assert_equal typo_article.extended, article.body
      assert_equal sites(:first), article.site
      assert_equal User.find_by_login(Typo::User.find(typo_article.user_id).login), article.updater
    end
  end
  
  def test_should_set_typo_body_to_mephisto_body_if_no_extended
    Typo.import_users
    typo_article = OpenStruct.new :title => 'typo article', :body => 'body', :categories => []
    assert_difference Article, :count do
      article = Typo.create_article(sites(:first), typo_article)
      assert_equal typo_article.body, article.body
      assert_nil article.excerpt
    end
  end
  
  def test_should_create_comment
    typo_comment = OpenStruct.new \
      :body       => 'This is a comment',
      :created_at => Time.now,
      :updated_at => Time.now,
      :created_at => Time.now,
      :author     => 'jim',
      :url        => 'http://jim.com',
      :email      => 'jim@jim.com',
      :ip         => '127.0.0.1'
    article = contents(:welcome)
    assert_difference Comment, :count do
      assert_difference article, :comments_count do
        comment = Typo.create_comment(article, typo_comment)
        article.reload
      end
    end
  end
end
