class MetaWeblogService < XmlRpcService
  web_service_api MetaWeblogApi
  before_invocation :authenticate

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
      :categories        => article.sections.collect { |c| c.name },
      :mt_text_more      => article.body.to_s,
      :mt_excerpt        => article.excerpt.to_s,
      # :mt_keywords       => article.keywords.to_s,
      # :mt_allow_comments => article.allow_comments? ? 1 : 0,
      # :mt_allow_pings    => article.allow_pings? ? 1 : 0,
      # :mt_convert_breaks => (article.text_filter.name.to_s rescue ''),
      # :mt_tb_ping_urls   => article.pings.collect { |p| p.url },
      :dateCreated       => (article.published_at rescue "")
      )
  end

  protected
    def article_url(article)
      article.published? && article.full_permalink
    end
    
    def post_it(article, user, password, struct, publish)
      article.attributes = {:updater => @user, :section_ids => Section.find(:all, :conditions => ['name IN (?)', struct['categories']]).collect(&:id),
        :body => struct['description'].to_s, :title => struct['title'].to_s, :excerpt => struct['mt_excerpt'].to_s}
      utc_date = Time.utc(struct['dateCreated'].year, struct['dateCreated'].month, struct['dateCreated'].day, struct['dateCreated'].hour, struct['dateCreated'].sec, struct['dateCreated'].min) rescue article.published_at

      article.published_at = publish == true ? utc_date : nil
      article.save!
      article.id
    end
end