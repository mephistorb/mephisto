require 'digest/md5'
module ApplicationHelper

  def author_link_for(comment)
    return comment.author if comment.author_url.blank?
    link_to h(comment.author), "#{'http://' unless comment.author_url =~ /^https?:\/\//}#{comment.author_url}"
  end

  def avatar_for(user, options = {})
    image_tag gravatar_url_for(user), {:class => 'avatar'}.merge(options)
  end
  def asset_title_for(asset)
    asset.title.blank? ? asset.filename : asset.title
  end

  def asset_image_for(asset, thumbnail = nil)
    image_tag asset.public_filename(thumbnail)
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

  if RAILS_ENV == 'development'
    def gravatar_url_for(user, size = 80)
      'avatar.gif'
    end
  else
    def gravatar_url_for(user, size = 80)
      "http://www.gravatar.com/avatar.php?size=#{size}&gravatar_id=#{Digest::MD5.hexdigest(user.email)}&default=http://#{request.host_with_port}/images/avatar.gif"
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
end
