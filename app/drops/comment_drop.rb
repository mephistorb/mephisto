class CommentDrop < BaseDrop
  include Mephisto::Liquid::UrlMethods
  include WhiteListHelper
  
  def comment() @source end

  def initialize(source)
    super
    @comment_liquid = %w(id author author_email author_ip created_at title published_at).inject({}) { |l, a| l.update(a => comment.send(a)) }
    @comment_liquid.update 'is_approved' => comment.approved?, 'body' => white_list(comment.body_html)
  end

  def before_method(method)
    @comment_liquid[method.to_s]
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