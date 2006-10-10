class ArticleDrop < BaseDrop
  include Mephisto::Liquid::UrlMethods
  
  timezone_dates :published_at, :updated_at
  liquid_attributes << :title << :permalink << :comments_count
  
  def article() @source end

  def initialize(source, options = {})
    super source
    @options        = options
    @liquid.update \
      'body'             => @source.body_html,
      'excerpt'          => (@source.excerpt_html.nil? || @source.excerpt_html.empty? ? nil : @source.excerpt_html),
      'accept_comments'  => @source.accept_comments?,
      'is_page_home'     => (options[:page] == true)
  end
  
  def author
    @author ||= liquidize(@source.user).first
  end

  def comments
    @comments ||= liquidize(*@source.comments.reject(&:new_record?))
  end
  
  def sections
    @sections ||= @source.sections.inject([]) { |all, s| s.home? ? all : all << s.to_liquid } # your days are numbered, home section!
    @sections ||= liquidize(*@source.sections) { |s| s.home? ? nil : s.to_liquid }
  end

  def tags
    @tags ||= liquidize(*@source.tags)
  end

  def blog_sections
    sections.select { |s| s.section.blog? }
  end
  
  def page_sections
    sections.select { |s| s.section.paged? }
  end
  
  def content
    @content ||= body_for_mode(@options[:mode] || :list)
  end

  def url
    @url ||= absolute_url(@site.permalink_for(@source))
  end

  def comments_feed_url
    @comments_feed_url ||= url + '/comments.xml'
  end

  def changes_feed_url
    @changes_feed_url ||= url + '/changes.xml'
  end

  protected
    def body_for_mode(mode)
      contents = [before_method(:excerpt), before_method(:body)]
      contents.reverse! if mode == :single
      contents.detect { |content| !content.blank? }.to_s.strip
    end
end