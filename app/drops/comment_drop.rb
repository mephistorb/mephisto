class CommentDrop < BaseDrop
  include Mephisto::Liquid::UrlMethods
  
  timezone_dates :published_at, :created_at
  liquid_attributes.push(:title) # Not sure who uses this.

  def initialize(source)
    super
    @liquid.update('is_approved' => @source.approved?,
                   'body' => ActionView::Base.white_list_sanitizer.sanitize(@source.body_html))

    # We used to escape these fields when we saved them to the database.
    # Now we've unescaped everything in the database, but we still need to
    # preserve backwards compatibility with old themes, which expect these
    # values to be escaped.  So we escape these fields manually here.
    [:author, :author_email, :author_ip].each do |a|
      @liquid.update(a.to_s => CGI.escapeHTML(@source.send(a) || ''))
    end
  end

  def author_url
    return nil if source.author_url.blank?
    CGI.escapeHTML(@source.author_url =~ /\Ahttps?:\/\// ? @source.author_url : "http://" + @source.author_url)
  end

  def url
    @url ||= absolute_url(@source.site.permalink_for(@source))
  end

  def new_record
    @source.new_record?
  end

  def author_link
    @source.author_url.blank? ? "<span>#{@liquid['author']}</span>" : %Q{<a href="#{author_url}">#{@liquid['author']}</a>}
  end
  
  def presentation_class
    @presentation_class ||= case @source.user_id
        when @source.article.user_id
          "by-author"
        when nil
          "by-guest"
        else
          "by-user"
      end
  end
end
