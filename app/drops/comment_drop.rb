class CommentDrop < BaseDrop
  include Mephisto::Liquid::UrlMethods
  
  timezone_dates :published_at, :created_at
  liquid_attributes.push(*[:author, :author_email, :author_ip, :title])

  def initialize(source)
    super
    @liquid.update 'is_approved' => @source.approved?, 'body' => ActionView::Base.white_list_sanitizer.sanitize(@source.body_html)
  end
  
  def author_url
    return nil if source.author_url.blank?
    @source.author_url =~ /^https?:\/\// ? @source.author_url : "http://" + @source.author_url
  end

  def url
    @url ||= absolute_url(@source.site.permalink_for(@source))
  end

  def new_record
    @source.new_record?
  end

  def author_link
    @source.author_url.blank? ? "<span>#{@source.author}</span>" : %Q{<a href="#{author_url}">#{@source.author}</a>}
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
