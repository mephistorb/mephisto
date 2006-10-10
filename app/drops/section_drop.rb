class SectionDrop < BaseDrop
  include Mephisto::Liquid::UrlMethods
  
  liquid_attributes.push(*[:name, :path, :archive_path])
  
  def current() @current == true end

  def initialize(source, current = false)
    super source
    @current        = current
    @liquid['articles_count'] = @source.send(:read_attribute, :articles_count)
    {:is_blog => :blog?, :is_paged => :paged?, :is_home => :home?}.each { |k, v| @liquid[k.to_s] = @source.send(v) }
  end
  
  def articles
    @articles ||= latest_articles
  end
  
  def comments
    @comments ||= latest_comments
  end

  def latest_articles(limit = nil)
    liquify(*@source.articles.find_by_date(:limit => (limit || @source.articles_per_page)))
  end

  def latest_comments(limit = nil)
    liquify(*@source.find_comments(:limit => (limit || @source.articles_per_page)))
  end

  def pages
    @pages ||= liquify(*@source.articles) { |article, i| article.to_liquid(:page => i.zero?) }
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