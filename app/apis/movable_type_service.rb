class MovableTypeService < XmlRpcService
  web_service_api MovableTypeApi
  before_invocation :authenticate, :except => [:supportedMethods, :supportedTextFilters]

  #def getRecentPostTitles(blogid, username, password, numberOfPosts)
  #  # FIXME not implemented
  #end

  def getCategoryList(blogid, username, password)
    site.sections.find(:all, :order => 'id ASC').collect { |c| MovableTypeStructs::Category.new(:categoryId => c.id, :categoryName => c.name) }
  end

  def getPostCategories(postid, username, password)
    article = @user.articles.find(postid)
    article.sections.collect { |c| MovableTypeStructs::Category.new(:categoryId => c.id, :categoryName => c.name) }
  end

  def setPostCategories(postid, username, password, categories)
    article = @user.articles.find(postid)
    article.section_ids= categories.collect { |c| c.categoryId }
    article.save!
    true
  end

  def supportedMethods
    MetaWeblogService.public_instance_methods(false).collect { |m| "metaWeblog.{#m}" } \
    + MovableTypeService.public_instance_methods(false).collect { |m| "mt.{#m}" }
  end

  def supportedTextFilters
    FilteredColumn.filters.collect { |(key, filter)| MovableTypeStructs::TextFilter.new(:key => key, :label => filter.filter_name) }
  end

  # def getTrackbackPings,
  #  ...
  # end

  #def publishPost(postid, username, password)
  #  article = @user.articles.find(postid)
  #  #article. hmmm now what?
  #  true
  #end

end
