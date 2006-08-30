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
    options = options.reverse_merge(:title => "#{asset.title} \n #{asset.tags.join(', ')}")
    if asset.movie?
      # non-image icon
      image_tag('/images/icons/video.png', options)
    elsif asset.audio?
      image_tag('/images/icons/audio.png', options)
    elsif asset.pdf? and request.env['HTTP_USER_AGENT'] =~ /webkit/i
      image_tag(asset.public_filename, {:class => 'pdf'}.merge(options))
    elsif asset.other?
      image_tag('/images/icons/doc.png', options)
      
    elsif asset.thumbnails_count.zero?
      # no thumbnails
      image_tag(asset.public_filename, options.update(:size => Array.new(2).fill(Asset.attachment_options[:thumbnails][thumbnail].to_i).join('x')))
    else
      image_tag(asset.public_filename(thumbnail), options)
    end
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
    link_to_remote image_tag('/images/icons/trash.gif', :class => 'iconb red'), 
      {:url => {:controller => file_type.to_s, :action => 'remove', :filename => resource, :context => context}, :confirm => 'Are you sure?  This deletion will be permanent.'}, 
       :class => 'aicon', :title => 'Delete resource'
  end

  if RAILS_ENV == 'development'
    def gravatar_url_for(user, size = 80)
      'avatar.gif'
    end
  else
    def gravatar_url_for(user, size = 80)
      return 'avatar.gif' unless user && user.email
      "http://www.gravatar.com/avatar.php?size=#{size}&gravatar_id=#{Digest::MD5.hexdigest(user.email)}&default=http://#{request.host_with_port}/images/avatar.gif"
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
