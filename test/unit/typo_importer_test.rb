require File.dirname(__FILE__) + '/../test_helper'
require 'convert/typo'
require 'ostruct'

class TypoImporterTest < Test::Unit::TestCase
  fixtures :contents, :sites

  def test_should_import_users
    assert_difference User, :count, 2 do
      assert_equal 2, Typo.import_users
    end
  end
  
  def test_should_create_sections
    fake_article1 = OpenStruct.new('categories' => [
        OpenStruct.new('name' => 'foo'),
      ]
    )
    fake_article2 = OpenStruct.new('categories' => [
        OpenStruct.new('name' => 'foo'),
        OpenStruct.new('name' => 'bar')
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
    typo_article = Typo::Article.find(1)
    assert_difference Article, :count do
      article = Typo.create_article(sites(:first), typo_article)
      assert_equal sites(:first), article.site
      assert_equal User.find_by_login(Typo::User.find(typo_article.user_id).login), article.updater
    end
  end
  
  def test_should_create_comment
    typo_comment = OpenStruct.new(
      "body" => 'This is a comment',
      "created_at" => Time.now,
      "updated_at" => Time.now,
      "created_at" => Time.now,
      "author" => 'jim',
      "url" => 'http://jim.com',
      "email" => 'jim@jim.com',
      "ip" => '127.0.0.1'
    )
    article = contents(:welcome)
    assert_difference Comment, :count do
      assert_difference article, :comments_count do
        comment = Typo.create_comment(article, typo_comment)
        article.reload
      end
    end
  end
end
