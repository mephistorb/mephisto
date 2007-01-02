require 'converters/typo/content'
require 'converters/typo/page'
require 'converters/typo/article'
require 'converters/typo/comment'
require 'converters/typo/category'
require 'converters/typo/user'
require 'converters/typo/tag'
require 'converters/typo/text_filter'

class TypoConverter < BaseConverter
  def self.convert(options = {})
    converter = new(options)
    converter.import_users do |typo_user|
      new_user = ::User.new \
        :email => typo_user.email || "#{typo_user.login}@notfound.com",
        :login                    => typo_user.login,
        :password                 => new_user_password,
        :password_confirmation    => new_user_password
      converter.users[typo_user.login] = new_user
    end
    converter.import_articles do |typo_article|
      unless typo_article.body.blank? || typo_article.title.blank?
        user = typo_article.user_id.nil? ? nil : converter.users[typo_article.user.login]
        
        excerpt, body = !typo_article.extended.blank? ?
          [typo_article.body, typo_article.extended] :
          [nil, typo_article.body]
        
        if typo_article.is_a?(Typo::Page)
          sec_ids = [converter.find_or_create_section("pages", "pages", true).id]
          tag_string = ""
        else # standard Article
          sec_ids = converter.find_or_create_sections(typo_article)
          tag_string = typo_article.tags.collect(&:name) * ', '
        end
        ::Article.new \
          :title        => typo_article.title, 
          :excerpt      => excerpt,
          :body         => body,
          :filter       => typo_article.filter ? typo_article.filter + "_filter" : (user.filter || converter.site.filter),
          :permalink    => typo_article.permalink,
          :created_at   => typo_article.created_at,
          :published_at => typo_article.created_at,
          :updated_at   => typo_article.updated_at,
          :user         => user,
          :updater      => user,
          :section_ids  => sec_ids,
          :tag          => tag_string
          :filter       => converter.old_filters
      end
    end
    
    converter.import_comments do |typo_comment|
      ::Comment.new \
        :body         => typo_comment.body,
        :filter       => typo_comment.filter ? typo_comment.filter + "_filter" : converter.site.filter,
        :created_at   => typo_comment.created_at,
        :updated_at   => typo_comment.updated_at,
        :published_at => typo_comment.created_at,
        :author       => typo_comment.author,
        :author_url   => typo_comment.url,
        :author_email => typo_comment.email,
        :author_ip    => typo_comment.ip
    end
  end

  def old_filters
    @old_filters ||= {
      Typo::TextFilter.find_by_name("markdown").id             => "markdown_filter",
      Typo::TextFilter.find_by_name("markdown smartypants").id => "smartypants_filter",
      Typo::TextFilter.find_by_name("textile").id              => "textile_filter" }
  end

  def old_articles
    @old_articles ||= ( Typo::Page.find(:all) + Typo::Article.find(:all) )
  end

  def old_users
    @old_users ||= Typo::User.find(:all).index_by(&:login)
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
      memo << find_or_create_section(cat.name, cat.permalink).id
    end
  end

  def find_or_create_section(name, permalink, paged = false)
    unless sec = sections[permalink]
      sec = site.sections.create(:name => name, :path => permalink, :show_paged_articles => paged)
      sec.save!
      sections[permalink] = sec
    end
    sec
  end

end