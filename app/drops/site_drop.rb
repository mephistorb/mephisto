class SiteDrop < BaseDrop
  def site() @source end
  def current_section() @current_section_liquid end

  def initialize(source, section = nil)
    @source                 = source
    @current_section        = section
    @current_section_liquid = section ? section.to_liquid : nil
    @site_liquid = [:id, :host, :subtitle, :title, :articles_per_page, :tag_path, :search_path].inject({}) { |h, k| h.merge k.to_s => @source.send(k) }
    @site_liquid['accept_comments'] = @source.accept_comments?
  end

  def before_method(method)
    @site_liquid[method.to_s]
  end

  def sections
    @sections ||= @source.sections.inject([]) { |all, s| all.send(s.home? ? :unshift : :<<, s.to_liquid(s == @current_section)) }
  end
  
  def home_section
    find_section ''
  end

  def latest_articles(limit = nil)
    return @articles if @articles && limit == @source.articles_per_page
    articles = returning @source.articles.find_by_date(:limit => (limit || @source.articles_per_page)) do |articles|
      articles.collect! &:to_liquid
    end
    limit == @source.articles_per_page ? (@articles = articles) : articles
  end

  def latest_comments(limit = nil)
    return @comments if @comments && limit == @source.articles_per_page
    comments = returning @source.comments.find(:all, :limit => (limit || @source.articles_per_page)) do |comments|
      comments.collect! &:to_liquid
    end
    limit == @source.articles_per_page ? (@comments = comments) : comments
  end

  def find_section(path)
    @section_index ||= {}
    return @section_index[path] if @section_index[path]
    @section_index[path] ||= @current_section_liquid if @current_section && @current_section.path == path
    @section_index[path] ||= @sections.detect { |s| s['path'] == path } if @sections
    @section_index[path] ||= @source.sections.find_by_path(path).to_liquid
  end
  
  def find_child_sections(path)
    returning @source.sections.find(:all, :conditions => ['path LIKE ?', "#{path}/%"]) do |sections|
      sections.collect! &:to_liquid
    end
  end
  
  def blog_sections
    sections.select { |s| s.section.blog? }
  end
  
  def page_sections
    sections.select { |s| s.section.paged? }
  end
  
  def tags
    @tags ||= @source.tags.collect &:name
  end
end