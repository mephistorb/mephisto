require 'digest/md5'
module ApplicationHelper

  def author_link_for(comment)
    return h(comment.author) if comment.author_url.blank?
    link_to h(comment.author), "#{'http://' unless comment.author_url =~ /^https?:\/\//}#{comment.author_url}"
  end

  def avatar_for(user, options = {})
    image_tag gravatar_url_for(user), {:class => 'avatar'}.merge(options)
  end

  def asset_title_for(asset)
    asset.title.blank? ? asset.filename : asset.title
  end

  def asset_image_for(asset, thumbnail = :tiny, options = {})
    image_tag(*asset_image_args_for(asset, thumbnail, options))
  end

  def todays_short_date
    utc_to_local(Time.now.utc).to_ordinalized_s(:stub)
  end
 
  def yesterdays_short_date
    utc_to_local(Time.now.utc.yesterday).to_ordinalized_s(:stub)
  end

  # TODO: write a select helper in the filtered column plugin for this
  def filter_options
    (FilteredColumn.filters.keys).inject([]) { |arr, key| arr << [FilteredColumn.filters[key].filter_name, key.to_s] }.unshift(['Plain HTML', ''])
  end
  
  def who(name)
    return current_user.login == name ? "You" : name
  end

  def delete_link(file_type, resource, context)
    link_to_remote image_tag('/images/mephisto/icons/trash.gif', :class => 'iconb red'), 
      {:url => url_for_theme(:controller => file_type.to_s, :action => 'remove', :filename => resource, :context => context), :confirm => 'Are you sure?  This deletion will be permanent.'}, 
       :class => 'aicon', :title => 'Delete resource'
  end

  # TODO - Some of the callers of this function could probably be fixed to
  # call something better.  Normally, adding the relative_url_root to a
  # path or URL is the responsibility of url_for.  But since we do some of
  # our own routing, it may not be that simple for us in all cases.
  def relative_url_root
    ActionController::Base.relative_url_root
  end

  # Make our form_authenticity_token token available to JavaScript.
  def init_mephisto_authenticity_token
    return "" unless protect_against_forgery?
    "Mephisto.token = '#{form_authenticity_token}';"
  end

  if RAILS_ENV == 'development'
    def gravatar_url_for(user, size = 80)
      'mephisto/avatar.gif'
    end
  else
    def gravatar_url_for(user, size = 80)
      return 'mephisto/avatar.gif' unless user && user.email
      "http://www.gravatar.com/avatar.php?size=#{size}&gravatar_id=#{Digest::MD5.hexdigest(user.email)}&default=http://#{request.host_with_port}#{relative_url_root}/images/mephisto/avatar.gif"
    end
  end

  def comment_expiration_options
    [['Are not allowed', -1],
     ['Never expire', 0], 
     ['Expire 24 hours after publishing',     1],
     ['Expire 1 week after publishing',       7],
     ['Expire 1 month after publishing',      30],
     ['Expire 3 months after publishing',     90]]
  end

  def sanitize_feed_content(html)
    returning h(sanitize(html.strip)) do |html|
      html.gsub! /&amp;(#\d+);/ do |s|
        "&#{$1};"
      end
    end
  end
end
