class SiteDrop < BaseDrop
  liquid_attributes.push(*[:host, :subtitle, :title, :articles_per_page, :tag_path, :search_path])
  def current_section() @current_section_liquid end

  def initialize(source, section = nil)
    super source
    @current_section        = section
    @current_section_liquid = section ? section.to_liquid : nil
    @liquid['accept_comments'] = @source.accept_comments?
  end

  def sections
    return @sections if @sections
    @sections = @source.sections.inject([]) { |all, s| all.send(s.home? ? :unshift : :<<, s.to_liquid(s == @current_section)) }
    @sections.each { |s| s.context = @context }
    @sections
  end
  
  def home_section
    find_section ''
  end

  def latest_articles(limit = nil)
    return @articles if @articles && limit == @source.articles_per_page
    articles = liquify(*@source.articles.find_by_date(:limit => (limit || @source.articles_per_page)))
    limit == @source.articles_per_page ? (@articles = articles) : articles
  end

  def latest_comments(limit = nil)
    return @comments if @comments && limit == @source.articles_per_page
    comments = liquify(*@source.comments.find(:all, :limit => (limit || @source.articles_per_page)))
    limit == @source.articles_per_page ? (@comments = comments) : comments
  end

  def find_section(path)
    @section_index ||= sections.inject({}) { |memo, section| memo.update section['path'] => section }
    @section_index[path]
  end

  def find_child_sections(path)
    path << '/' unless path.empty?
    sections.select { |s| s['path'] != path && s['path'] =~ %r(^#{Regexp.escape path}[^/]+$) }
  end
  
  def find_descendant_sections(path)
    path << '/' unless path.empty?
    sections.select { |s| s['path'] != path && s['path'] =~ %r(^#{Regexp.escape path}) }
  end
  
  def blog_sections
    sections.select { |s| s.source.blog? }
  end
  
  def page_sections
    sections.select { |s| s.source.paged? }
  end
  
  def tags
    @tags ||= @source.tags.collect &:name
  end
end
