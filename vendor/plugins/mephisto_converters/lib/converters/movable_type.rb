require 'converters/movable_type/blog'
require 'converters/movable_type/entry'
require 'converters/movable_type/comment'
require 'converters/movable_type/author'
require 'converters/movable_type/category'
require 'converters/movable_type/placement'

class MovableTypeConverter < BaseConverter
  cattr_accessor :old_site
  
  def self.convert(options = {})
    converter = new(options)
    self.old_site = MovableType::Blog.find(options[:blog_id])

    converter.import_users do |mt_user|
      ::User.new \
        :login                    => mt_user.author_name,
        :email                    => mt_user.author_email || "#{mt_user.author_login}@notfound.com",
        :password                 => new_user_password,
        :password_confirmation    => new_user_password
    end

    converter.import_articles do |mt_article|
      user = converter.users[mt_article.author.user_login] rescue nil
      ::Article.new \
        :title        => mt_article.entry_title, 
        :excerpt      => mt_article.entry_excerpt, 
        :body         => "#{mt_article.entry_text}#{"\n" unless mt_article.entry_text[-1..-1] == "\n"}#{mt_article.entry_text_more}",
        :created_at   => mt_article.entry_created_on,
        :published_at => mt_article.entry_created_on,
        :updated_at   => mt_article.entry_modified_on,
        :user         => user,
        :updater      => user,
        :tag          => mt_article.placements.collect {|p| p.category.category_label},
        :section_ids  => converter.find_or_create_sections(mt_article)
    end
    
    converter.import_comments do |mt_comment|
      user = converter.users[mt_comment.commenter.user_login] rescue nil
      ::Comment.new \
        :body         => mt_comment.comment_text,
        :created_at   => mt_comment.comment_created_on,
        :updated_at   => mt_comment.comment_modified_on,
        :published_at => mt_comment.comment_created_on,
        :author       => mt_comment.comment_author,
        :author_url   => mt_comment.comment_url,
        :author_email => mt_comment.comment_email,
        :author_ip    => mt_comment.comment_ip,
        :user         => user
    end
  end

  def old_articles
    @old_articles ||= self.class.old_site.entries.find_by_entry_status(2)  # published
  end

  def old_users
    @old_users ||= begin
      MovableType::Author.find(:all).index_by &:author_name
    end
  end

  def get_login(mt_user)
    mt_user.author_name
  end

  def handle_bad_user_email(mt_user, email)
    mt_user.author_email = email
  end

  def handle_bad_comment_author_email(mt_comment, email)
    mt_comment.comment_email = email
  end
  
  def handle_bad_comment_author_url(mt_comment, url)
    mt_comment.comment_url = url
  end
  
  def handle_bad_comment_author(mt_comment, author)
    mt_comment.comment_author = author
  end
  
  def handle_bad_comment_content(mt_comment, content)
    mt_comment.comment_text = content
  end
  
  def find_or_create_sections(mt_article)
    cat_name = mt_article.category.category_label rescue ""
    sections[::Section.permalink_for(cat_name)] || site.sections.create(:name => cat_name)
  end
end
