require 'convert/typo/content'
require 'convert/typo/page'
require 'convert/typo/article'
require 'convert/typo/comment'
require 'convert/typo/category'
require 'convert/typo/user'
module Typo
  class << self
    # migrate users over, sorta ...
    def import_users
      newpass = 'mephistomigrator'
      users = 0

      Typo::User.find(:all).each do |typo_user|
        ActiveRecord::Base.logger.info "Creating new user for #{typo_user.login}"
        unless ::User.find_by_email(typo_user.email)
          new_user = ::User.create(
            :email => typo_user.email || 'foo@bar.com',
            :login                    => typo_user.login,
            :password                 => newpass,
            :password_confirmation    => newpass
          )
          unless new_user.valid?
            ActiveRecord::Base.logger.info "New user errors: #{new_user.errors.to_yaml}"
            raise "User creation failed (see log for details)"
          end
          users += 1
        end
      end
      users
    end

    def find_or_create_sections(typo_article)
      home_section = Section.find_by_name 'home'
      section_ids = typo_article.categories.inject([home_section.id]) { |a, c| a << ::Section.find_or_create_by_name(c.name).id }
    end

    def create_article(site, typo_article)
      default_user = ::User.find(:first)

      user = typo_article.user_id.nil? ? 
        default_user : 
        ::User.find_by_login(Typo::User.find(typo_article.user_id).login)

      section_ids = find_or_create_sections(typo_article)

      ::Article.create! \
        :site         => site,
        :title        => typo_article.title, 
        :excerpt      => typo_article.excerpt,
        :body         => typo_article.body,
        :created_at   => typo_article.created_at,
        :published_at => typo_article.created_at,
        :updated_at   => typo_article.updated_at,
        :user         => user,
        :updater      => user,
        :section_ids  => section_ids
    end

    def create_comment(article, typo_comment)
      comment = article.comments.create! \
        :body         => typo_comment.body,
        :created_at   => typo_comment.created_at,
        :updated_at   => typo_comment.updated_at,
        :published_at => typo_comment.created_at,
        :author       => typo_comment.author,
        :author_url   => typo_comment.url,
        :author_email => typo_comment.email,
        :author_ip    => typo_comment.ip
      comment.approved = true
      comment.save
    end

    def import_articles(site)
      articles = 0
      comments = 0

      Typo::Article.find_all_by_type('Article').each do |typo_article|
        article = create_article(site, typo_article)
        articles += 1

        ActiveRecord::Base.logger.info "Creating article comments"
        typo_article.comments.each do |typo_comment|
          ActiveRecord::Base.logger.info "adding comment"
          create_comment(article, typo_comment)
          comments += 1
        end
      end
      [articles, comments]
    end

    def convert(site)
      totals       = { :users => 0, :articles => 0, :comments => 0 }
      ActiveRecord::Base.transaction do
        totals[:users] = import_users
        puts "migrated #{totals[:users]} user(s)..."
        totals[:articles], totals[:comments] = import_articles(site)
        puts "migrated #{totals[:articles]} article(s) and #{totals[:comments]} comment(s)..."
      end
    end
  end
end
