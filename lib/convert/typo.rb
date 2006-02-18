require 'convert/typo/content'
require 'convert/typo/page'
require 'convert/typo/article'
require 'convert/typo/comment'
require 'convert/typo/tag'
require 'convert/typo/user'
module Typo
  def self.convert
    newpass = 'mephistomigrator'
    # migrate users over, sorta ...
    Typo::User.find(:all).each do |user|
      email = 'foo@bar.com' if user.email.nil?
      u     = ::User.create \
        :login                 => user.login, 
        :email                 => email,
        :password              => newpass,
        :password_confirmation => newpass
    end

    Typo::Article.find_all_by_type('Article').each do |article|

      user = article.user_id.nil? ? 
        ::User.find(:first) : 
        ::User.find_by_login(Typo::User.find(article.user_id).login)

      user.create_article \
        :title        => article.title, 
        :excerpt      => article.body,
        :body         => article.extended,
        :created_at   => article.created_at,
        :published_at => article.created_at,
        :updated_at   => article.updated_at

      article.categories.each { |category| a.categorizations.create :category => ::Category.find_or_create_by_name(category.name) }

      Typo::Comment.find_all_by_article_id(article.id).each do |comment|
        user.article.comments.create \
          :body         => comment.body,
          :created_at   => comment.created_at,
          :updated_at   => comment.updated_at,
          :published_at => comment.created_at,
          :author       => comment.author,
          :author_url   => comment.url,
          :author_email => comment.email,
          :author_ip    => comment.ip
      end
    end
  end
end
