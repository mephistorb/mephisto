# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def author_link_for(comment)
    return comment.author if comment.author_url.blank?
    link_to comment.author, "#{'http://' unless comment.author_url =~ /^https?:\/\//}#{comment.author_url}"
  end

  def avatar_for(user, options = {})
    image_tag user.gravatar_url, {:class => 'avatar'}.merge(options)
  end
 
  def todays_short_date
    utc_to_local(Time.now.utc).to_ordinalized_s(:stub)
  end
 
  def yesterdays_short_date
    utc_to_local(Time.now.utc.yesterday).to_ordinalized_s(:stub)
  end

  def filter_options
    [['Plain HTML', ''], ['Textile', 'textile_filter'], ['Markdown', 'markdown_filter'], ['Markdown with Smarty Pants', 'smartypants']]
  end
  
  def who(name)
    return current_user.login == name ? "You" : name
  end

end
