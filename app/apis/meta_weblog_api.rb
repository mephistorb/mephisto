module MetaWeblogStructs
  class Article < ActionWebService::Struct
    member :description,        :string
    member :title,              :string
    member :postid,             :string
    member :url,                :string
    member :link,               :string
    member :permaLink,          :string
    member :sections,          [:string]
    member :mt_text_more,       :string
    member :mt_excerpt,         :string
    member :mt_keywords,        :string
    member :mt_allow_comments,  :int
    member :mt_allow_pings,     :int
    member :mt_convert_breaks,  :string
    member :mt_tb_ping_urls,   [:string]
    member :dateCreated,        :time
  end

  class MediaObject < ActionWebService::Struct
    member :bits, :string
    member :name, :string
    member :type, :string
  end

  class Url < ActionWebService::Struct
    member :url, :string
  end
end

class MetaWeblogApi < ActionWebService::API::Base
  inflect_names false

  api_method :getCategories,
    :expects => [ {:blogid => :string}, {:username => :string}, {:password => :string} ],
    :returns => [[:string]]

  api_method :getPost,
    :expects => [ {:postid => :string}, {:username => :string}, {:password => :string} ],
    :returns => [MetaWeblogStructs::Article]

  api_method :getRecentPosts,
    :expects => [ {:blogid => :string}, {:username => :string}, {:password => :string}, {:numberOfPosts => :int} ],
    :returns => [[MetaWeblogStructs::Article]]

  api_method :deletePost,
    :expects => [ {:appkey => :string}, {:postid => :string}, {:username => :string}, {:password => :string}, {:publish => :int} ],
    :returns => [:bool]

  api_method :editPost,
    :expects => [ {:postid => :string}, {:username => :string}, {:password => :string}, {:struct => MetaWeblogStructs::Article}, {:publish => :int} ],
    :returns => [:bool]

  api_method :newPost,
    :expects => [ {:blogid => :string}, {:username => :string}, {:password => :string}, {:struct => MetaWeblogStructs::Article}, {:publish => :int} ],
    :returns => [:string]

  api_method :newMediaObject,
    :expects => [ {:blogid => :string}, {:username => :string}, {:password => :string}, {:data => MetaWeblogStructs::MediaObject} ],
    :returns => [MetaWeblogStructs::Url]
    
end

class MetaWeblogService < ActionWebService::Base
  web_service_api MetaWeblogApi
  before_invocation :authenticate

  attr_accessor :controller

  delegate :site, :to => :controller

  def initialize(controller)
    @controller = controller
  end

  def getCategories(blogid, username, password)
    site.sections.find(:all).collect &:name
  end

  def getPost(postid, username, password)
    article = @user.articles.find(postid)
    article_dto_from(article)
  end

  def getRecentPosts(blogid, username, password, numberOfPosts)
    @user.articles.find(:all, :order => "created_at DESC", :limit => numberOfPosts).collect{ |c| article_dto_from(c) }
  end

  def newPost(blogid, username, password, struct, publish)
    article = @user.articles.build :site => site
    post_it(article, username, password, struct, publish)
  end
  
  def editPost(postid, username, password, struct, publish)
    article = @user.articles.find(postid)
    post_it(article, username, password, struct, publish)
    true
  end
  
  def deletePost(appkey, postid, username, password, publish)
    article = @user.articles.find(postid)
    article.destroy
    true
  end

  #def newMediaObject(blogid, username, password, data)
  #  resource = @user.resources.create(:filename => data['name'], :created_at => Time.now)
  #  resource.write_to_disk(data['bits'])
  #
  #  MetaWeblogStructs::Url.new("url" => controller.url_for(:controller => "/files/#{resource.filename}"))
  #end

  def article_dto_from(article)
    MetaWeblogStructs::Article.new(
      :description       => article.body,
      :title             => article.title,
      :postid            => article.id.to_s,
      :url               => article_url(article).to_s,
      :link              => article_url(article).to_s,
      :permaLink         => article.permalink.to_s,
      :sections          => article.sections.collect { |c| c.name },
      :mt_text_more      => article.body.to_s,
      :mt_excerpt        => article.excerpt.to_s,
      # :mt_keywords       => article.keywords.to_s,
      # :mt_allow_comments => article.allow_comments? ? 1 : 0,
      # :mt_allow_pings    => article.allow_pings? ? 1 : 0,
      # :mt_convert_breaks => (article.text_filter.name.to_s rescue ''),
      # :mt_tb_ping_urls   => article.pings.collect { |p| p.url },
      :dateCreated       => (article.published_at.to_formatted_s(:db) rescue "")
      )
  end

  protected
    def article_url(article)
      article.published? && article.full_permalink
    end
    
    def server_url
      controller.url_for(:only_path => false, :controller => "/")
    end
    
    def pub_date(time)
      time.strftime "%a, %e %b %Y %H:%M:%S %Z"
    end
    
    def authenticate(name, args)
      method = self.class.web_service_api.api_methods[name]
    
      # Coping with backwards incompatibility change in AWS releases post 0.6.2
      begin
        h = method.expects_to_hash(args)
        raise "Invalid login" unless @user = User.authenticate(h[:username], h[:password])
      rescue NoMethodError
        username, password = method[:expects].index(:username=>String), method[:expects].index(:password=>String)
        raise "Invalid login" unless @user = User.authenticate(args[username], args[password])
      end
    end
    
    def post_it(article, user, password, struct, publish)
      article.attributes = {:updater => @user, :section_ids => Section.find(:all, :conditions => ['name IN (?)', struct['sections']]).collect(&:id),
        :body => struct['description'].to_s, :title => struct['title'].to_s, :excerpt => struct['mt_excerpt'].to_s}

      utc_date = Time.utc(struct['dateCreated'].year, struct['dateCreated'].month, struct['dateCreated'].day, struct['dateCreated'].hour, struct['dateCreated'].sec, struct['dateCreated'].min)

      article.published_at = publish ? utc_date : nil
      article.save!
      article.id
    end
end