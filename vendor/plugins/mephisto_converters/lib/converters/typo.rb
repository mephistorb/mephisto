require 'converters/typo/content'
require 'converters/typo/page'
require 'converters/typo/article'
require 'converters/typo/comment'
require 'converters/typo/category'
require 'converters/typo/user'
require 'converters/typo/tag'

class TypoConverter < BaseConverter
  def self.convert(options = {})
    converter = new(options)
    converter.import_users do |typo_user|
      ::User.new \
        :email => typo_user.email || "#{typo_user.login}@notfound.com",
        :login                    => typo_user.login,
        :password                 => new_user_password,
        :password_confirmation    => new_user_password
    end
    converter.import_articles do |typo_article|
      unless typo_article.body.blank? || typo_article.title.blank?
        user = typo_article.user_id.nil? ? nil : converter.users[Typo::User.find(typo_article.user_id).login]
        
        excerpt, body = !typo_article.extended.blank? ?
          [typo_article.body, typo_article.extended] :
          [nil, typo_article.body]
        
        ::Article.new \
          :title        => typo_article.title, 
          :excerpt      => excerpt,
          :body         => body,
          :created_at   => typo_article.created_at,
          :published_at => typo_article.created_at,
          :updated_at   => typo_article.updated_at,
          :user         => user,
          :updater      => user,
          :section_ids  => converter.find_or_create_sections(typo_article),
          :tag          => typo_article.tags.collect(&:name) * ','
      end
    end
    
    converter.import_comments do |typo_comment|
      ::Comment.new \
        :body         => typo_comment.body,
        :created_at   => typo_comment.created_at,
        :updated_at   => typo_comment.updated_at,
        :published_at => typo_comment.created_at,
        :author       => typo_comment.author,
        :author_url   => typo_comment.url,
        :author_email => typo_comment.email,
        :author_ip    => typo_comment.ip,
    end
  end

  def old_articles
    @old_articles ||= Typo::Article.find_all_by_type('Article')
  end

  def old_users
    @old_users ||= Typo::User.find(:all).index_by &:login
  end

  def handle_bad_comment_author_email(typo_comment, email)
    typo_comment.email = email
  end
  
  def handle_bad_comment_author_url(typo_comment, url)
    typo_comment.url = url
  end
  
  def handle_bad_comment_content(typo_comment, content)
    typo_comment.body = content
  end

  def find_or_create_sections(typo_article)
    home_section = sections['']
    typo_article.categories.inject([home_section.id]) do |memo, cat|
      memo << (sections[::Section.permalink_for(cat.name)] || site.sections.create(:name => cat.name)).id
    end
  end
end