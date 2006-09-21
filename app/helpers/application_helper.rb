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
      {:url => {:controller => file_type.to_s, :action => 'remove', :filename => resource, :context => context}, :confirm => 'Are you sure?  This deletion will be permanent.'}, 
       :class => 'aicon', :title => 'Delete resource'
  end

  if RAILS_ENV == 'development'
    def gravatar_url_for(user, size = 80)
      'mephisto/avatar.gif'
    end
  else
    def gravatar_url_for(user, size = 80)
      return 'mephisto/avatar.gif' unless user && user.email
      "http://www.gravatar.com/avatar.php?size=#{size}&gravatar_id=#{Digest::MD5.hexdigest(user.email)}&default=http://#{request.host_with_port}/images/mephisto/avatar.gif"
    end
  end

  def pagination_remote_links(paginator, options={}, html_options={})
     name   = options[:name]    || ActionController::Pagination::DEFAULT_OPTIONS[:name]
     params = (options[:params] || ActionController::Pagination::DEFAULT_OPTIONS[:params]).clone
     
     pagination_links_each(paginator, options) do |n|
       params[name] = n
       link_to_function n.to_s, "window.spotlight.search('#{n}')"
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
