# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def avatar_for(user, options = {})
    image_tag "/#{user.avatar.full_path}", {:class => 'avatar'}.merge(options)
  end
  
end
