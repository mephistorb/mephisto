require 'convert/typo/content'
require 'convert/typo/page'
require 'convert/typo/article'
require 'convert/typo/comment'
require 'convert/typo/category'
require 'convert/typo/user'
module Typo
  def self.convert
    totals       = { :users => 0, :articles => 0, :comments => 0 }
    home_section = Section.find_by_name 'home'
    newpass      = 'mephistomigrator'
    # migrate users over, sorta ...
    Typo::User.find(:all).each do |typo_user|
      ::User.find_or_create_by_email typo_user.email || 'foo@bar.com',
        :login                    => typo_user.login,
        :password                 => newpass,
        :password_confirmation    => newpass
      totals[:users] += 1
    end
    
    puts "migrated #{totals[:users]} user(s)..."

    default_user = ::User.find(:first)
    Typo::Article.find_all_by_type('Article').each do |typo_article|
      user = typo_article.user_id.nil? ? 
        default_user : 
        ::User.find_by_login(Typo::User.find(typo_article.user_id).login)

      section_ids = typo_article.categories.inject([home_section.id]) { |a, c| a << ::Section.find_or_create_by_name(c.name).id }
      article     = ::Article.create \
        :title        => typo_article.title, 
        :excerpt      => typo_article.excerpt,
        :body         => typo_article.body,
        :created_at   => typo_article.created_at,
        :published_at => typo_article.created_at,
        :updated_at   => typo_article.updated_at,
        :user         => user,
        :section_ids  => section_ids

      totals[:articles] += 1

      typo_article.comments.each do |typo_comment|
        article.comments.create \
          :body         => typo_comment.body,
          :created_at   => typo_comment.created_at,
          :updated_at   => typo_comment.updated_at,
          :published_at => typo_comment.created_at,
          :author       => typo_comment.author,
          :author_url   => typo_comment.url,
          :author_email => typo_comment.email,
          :author_ip    => typo_comment.ip

        totals[:comments] += 1
      end
    end

    puts "migrated #{totals[:articles]} article(s) and #{totals[:comments]} comment(s)..."
  end
end
