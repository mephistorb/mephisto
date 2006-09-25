class SectionDrop < BaseDrop
  include Mephisto::Liquid::UrlMethods
  
  def section() @source end
  def current() @current == true end

  def initialize(source, current = false)
    @source         = source
    @current        = current
    @section_liquid = [:id, :name, :path, :archive_path].inject({}) { |h, k| h.update k.to_s => @source.send(k) }
    @section_liquid['articles_count'] = @source.send(:read_attribute, :articles_count)
    {:is_blog => :blog?, :is_paged => :paged?, :is_home => :home?}.each { |k, v| @section_liquid[k.to_s] = @source.send(v) }
  end

  def before_method(method)
    @section_liquid[method.to_s]
  end
  
  def articles
    @articles ||= latest_articles
  end
  
  def comments
    @comments ||= latest_comments
  end

  def latest_articles(limit = nil)
    returning @source.articles.find_by_date(:limit => (limit || @source.articles_per_page)) do |articles|
      articles.collect! &:to_liquid
    end
  end

  def latest_comments(limit = nil)
    returning @source.find_comments(:limit => (limit || @source.articles_per_page)) do |comments|
      comments.collect! &:to_liquid
    end
  end

  def pages
    return @pages if @pages
    @pages = returning [] do |pages|
      @source.articles.each_with_index do |article, i|
        pages << article.to_liquid(:page => i.zero?, :site => @context['site'].source)
      end
    end
  end

  def url
    @url ||= absolute_url(*@source.to_url)
  end
  
  def earliest_month
    @earliest_month ||= @source.articles.find_by_date(:limit => 1, :order => 'published_at').first.published_at.beginning_of_month.to_date rescue :false
  end
  
  def months
    if @months.nil?
      this_month = Time.now.utc.beginning_of_month.to_date
      date       = earliest_month.is_a?(Date) && earliest_month
      @months = []
      while date && date <= this_month
        @months << date
        date = date >> 1
      end
      @months.reverse!
    end
    
    @months
  end
end