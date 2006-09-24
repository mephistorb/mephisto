require 'converters/typo/content'
require 'converters/typo/page'
require 'converters/typo/article'
require 'converters/typo/comment'
require 'converters/typo/category'
require 'converters/typo/user'
require 'converters/typo/tag'

module Typo
  @@new_user_password = 'mephistomigrator'
  mattr_accessor :new_user_password

  class << self
    # migrate users over, sorta ...
    def import_users
      users = 0
      Typo::User.find(:all).each do |typo_user|
        users += 1 if import_user(typo_user)
      end
      users
    end

    def import_user(typo_user)
      ActiveRecord::Base.logger.info "Creating new user for #{typo_user.login}"
      unless ::User.find_by_login(typo_user.login)
        typo_user.email = nil if typo_user.email.blank?
        new_user = ::User.create(
          :email => typo_user.email || "#{typo_user.login}@notfound.com",
          :login                    => typo_user.login,
          :password                 => ::Typo.new_user_password,
          :password_confirmation    => ::Typo.new_user_password,
          :filter                   => 'textile_filter'
        )
        unless new_user.valid?
          ActiveRecord::Base.logger.info "New user errors: #{new_user.errors.to_yaml}"
          raise "User creation failed (see log for details)"
        end
        return new_user
      end
    end

    def find_or_create_sections(typo_article)
      site         = ::Site.find(1)
      home_section = site.sections.home
      section_ids = typo_article.categories.inject([home_section.id]) do |a, c|
        a << (site.sections.find_by_path(::Section.permalink_for(c.name)) || site.sections.create(:name => c.name)).id
      end
    end

    def create_article(site, typo_article)
      default_user = ::User.find(:first)

      user = typo_article.user_id.nil? ? 
        default_user : 
        ::User.find_by_login(Typo::User.find(typo_article.user_id).login)

      section_ids = find_or_create_sections(typo_article)
      
      tags = typo_article.tags.map { |tag| tag.name }
      tags = tags.join(',')
      
      excerpt, body = !typo_article.extended.blank? ?
        [typo_article.body, typo_article.extended] :
        [nil, typo_article.body]

      ::Article.create! \
        :site         => site,
        :title        => typo_article.title, 
        :excerpt      => excerpt,
        :body         => body,
        :created_at   => typo_article.created_at,
        :published_at => typo_article.created_at,
        :updated_at   => typo_article.updated_at,
        :user         => user,
        :updater      => user,
        :section_ids  => section_ids,
        :tag          => tags,
        :filter       => 'textile_filter'
    rescue
      msg = "Errored while converting Typo Article ##{typo_article.id}: '#{typo_article.title}'"
      puts msg
      RAILS_DEFAULT_LOGGER.warn msg
      RAILS_DEFAULT_LOGGER.warn "#{$!.class.name}: #{$!.to_s}"
      $!.backtrace.each { |b| RAILS_DEFAULT_LOGGER.warn " > #{b}" }
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
        :author_ip    => typo_comment.ip || '127.0.0.1',
        :filter       => 'textile_filter'
      comment.approved = true
      comment.save
    rescue
      msg = "Errored while converting Typo Comment ##{typo_comment.id}"
      puts msg
      RAILS_DEFAULT_LOGGER.warn msg
      RAILS_DEFAULT_LOGGER.warn "#{$!.class.name}: #{$!.to_s}"
      $!.backtrace.each { |b| RAILS_DEFAULT_LOGGER.warn " > #{b}" }
    end

    def import_articles(site)
      articles = 0
      comments = 0

      Typo::Article.find_all_by_type('Article').each do |typo_article|
        next if typo_article.body.blank? || typo_article.title.blank?
        
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
