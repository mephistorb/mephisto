class CommentDrop < BaseDrop
  include Mephisto::Liquid::UrlMethods
  include WhiteListHelper
  
  timezone_dates :published_at, :created_at
  liquid_attributes.push(*[:author, :author_email, :author_ip, :title])
  
  def comment() @source end

  def initialize(source)
    super
    @liquid.update 'is_approved' => comment.approved?, 'body' => white_list(comment.body_html)
  end
  
  def author_url
    return nil if comment.author_url.blank?
    comment.author_url =~ /^https?:\/\// ? comment.author_url : "http://" + comment.author_url
  end

  def url
    @url ||= absolute_url(@source.site.permalink_for(@source))
  end

  def author_link
    comment.author_url.blank? ? "<span>#{CGI::escapeHTML(comment.author)}</span>" : %Q{<a href="#{CGI::escapeHTML author_url}">#{CGI::escapeHTML comment.author}</a>}
  end
end