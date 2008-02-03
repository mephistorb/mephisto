require 'converters/word_press/post'
require 'converters/word_press/comment'
require 'converters/word_press/user'
require 'converters/word_press/term'
require 'converters/word_press/term_relationship'
require 'converters/word_press/term_taxonomy'
class WordPressConverter < BaseConverter
  def self.convert(options = {})
    converter = new(options)
    converter.import_users do |wp_user|
      ::User.new \
        :email => wp_user.user_email || "#{wp_user.user_login}@notfound.com",
        :login                    => wp_user.user_login,
        :password                 => new_user_password,
        :password_confirmation    => new_user_password
    end

    converter.import_articles do |wp_article|
      unless wp_article.post_content.blank? || wp_article.post_title.blank?
        user        = wp_article.post_author.nil? ? nil : converter.users[WordPress::User.find(wp_article.post_author.to_i).user_login]
        
        excerpt, body = !wp_article.post_excerpt.blank? ?
          [wp_article.post_excerpt, wp_article.post_content] :
          [nil, wp_article.post_content]
        
        ::Article.new \
          :title        => wp_article.post_title, 
          :excerpt      => excerpt,
          :body         => body,
          :created_at   => wp_article.post_date,
          :published_at => wp_article.post_date,
          :updated_at   => wp_article.post_modified,
          :user         => user,
          :updater      => user,
          :tag          => converter.tagging_from_sections(wp_article),
          :section_ids  => converter.find_or_create_sections(wp_article),
          :filter       => ''
      end
    end
    
    converter.import_comments do |wp_comment|
      ::Comment.new \
        :body         => wp_comment.comment_content,
        :created_at   => wp_comment.comment_date,
        :updated_at   => wp_comment.comment_date,
        :published_at => wp_comment.comment_date,
        :author       => wp_comment.comment_author,
        :author_url   => wp_comment.comment_author_url,
        :author_email => wp_comment.comment_author_email,
        :author_ip    => wp_comment.comment_author_IP
    end
  end

  def old_articles
    @old_articles ||= WordPress::Post.find_all_by_post_status('publish')
  end

  def old_users
    @old_users ||= WordPress::User.find(:all).index_by &:user_login
  end

  def get_login(wp_user)
    wp_user.user_login
  end

  def handle_bad_user_email(wp_user, email)
    wp_user.user_email = email
  end

  def handle_bad_comment_author_email(wp_comment, email)
    wp_comment.comment_author_email = email
  end
  
  def handle_bad_comment_author_url(wp_comment, url)
    wp_comment.comment_author_url = url
  end
  
  def handle_bad_comment_author(wp_comment, author)
    wp_comment.comment_author = author
  end
  
  def handle_bad_comment_content(wp_comment, content)
    wp_comment.comment_content = content
  end
  
  def tagging_from_sections(wp_article)
    wp_article.tags.join(',')
  end

  def find_or_create_sections(wp_article)
    home_section = sections['']
    wp_article.categories.inject([home_section.id]) do |memo, cat|
      existing = Section.find_by_name(cat)
      if (existing)
        memo << existing.id
      else
        new = site.sections.create(:name => cat)
        new.save!
        memo << new.id
      end
    end
  end
end
