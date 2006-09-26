require 'converters/word_press/post'
require 'converters/word_press/comment'
require 'converters/word_press/category'
require 'converters/word_press/post_category'
require 'converters/word_press/user'
module WordPress
  @@new_user_password = 'mephistomigrator'
  mattr_accessor :new_user_password

  class << self
    def import_users
      users = 0
      WordPress::User.find(:all).each do |wp_user|
        users += 1 if import_user(wp_user)
      end
      users
    end

    def import_user(wp_user)
      ActiveRecord::Base.logger.info "Creating new user for #{wp_user.user_login}"
      unless ::User.find_by_login(wp_user.user_login)
        wp_user.user_email = nil if wp_user.user_email.blank?
        new_user = ::User.create(
          :email => wp_user.user_email || "#{wp_user.user_login}@notfound.com",
          :login                    => wp_user.user_login,
          :password                 => new_user_password,
          :password_confirmation    => new_user_password,
          :filter                   => 'textile_filter'
        )
        unless new_user.valid?
          ActiveRecord::Base.logger.info "New user errors: #{new_user.errors.to_yaml}"
          raise "User creation failed (see log for details)"
        end
        return new_user
      end
    end

    def find_or_create_sections(wp_article)
      site         = ::Site.find(1)
      home_section = site.sections.home
      section_ids = wp_article.categories.inject([home_section.id]) do |a, c|
        a << (site.sections.find_by_path(::Section.permalink_for(c.cat_name)) || site.sections.create(:name => c.cat_name)).id
      end
    end

    def create_article(site, wp_article)
      default_user = ::User.find(:first)

      user = wp_article.post_author.nil? ? 
        default_user : 
        ::User.find_by_login(WordPress::User.find(wp_article.post_author.to_i).user_login)

      section_ids = find_or_create_sections(wp_article)
      
      excerpt, body = !wp_article.post_excerpt.blank? ?
        [wp_article.post_excerpt, wp_article.post_content] :
        [nil, wp_article.post_content]

      ::Article.create! \
        :site         => site,
        :title        => wp_article.post_title, 
        :excerpt      => excerpt,
        :body         => body,
        :created_at   => wp_article.post_date,
        :published_at => wp_article.post_date,
        :updated_at   => wp_article.post_modified,
        :user         => user,
        :updater      => user,
        :section_ids  => section_ids,
        :filter       => 'textile_filter'
    end

    def create_comment(article, wp_comment)
      comment = article.comments.create! \
        :body         => wp_comment.comment_content,
        :created_at   => wp_comment.comment_date,
        :updated_at   => wp_comment.comment_date,
        :published_at => wp_comment.comment_date,
        :author       => wp_comment.comment_author,
        :author_url   => wp_comment.comment_author_url,
        :author_email => wp_comment.comment_author_email,
        :author_ip    => wp_comment.comment_author_IP,
        :filter       => 'textile_filter'
        comment.approved = (wp_comment.comment_approved.to_i == 1)
      comment.save!
    end

    def import_articles(site)
      articles = 0
      comments = 0

      WordPress::Post.find_all_by_post_status('publish').each do |wp_article|
        next if wp_article.post_content.blank? or wp_article.post_title.blank?
        
        article = create_article(site, wp_article)
        articles += 1

        ActiveRecord::Base.logger.info "Creating article comments"
        wp_article.comments.each do |wp_comment|
          ActiveRecord::Base.logger.info "adding comment"
          create_comment(article, wp_comment)
          comments += 1
        end
      end
      [articles, comments]
    end

    def convert(site)
      totals = { :users => 0, :articles => 0, :comments => 0}
      ActiveRecord::Base.transaction do
        totals[:users] = import_users
        puts "migrated #{totals[:users]} user(s)..."
        totals[:articles], totals[:comments], totals[:sections] = import_articles(site)
        puts "migrated #{totals[:articles]} article(s) with #{totals[:comments]} comment(s)"
      end
    end
  end
end