# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def avatar_for(user, options = {})
    image_tag "/#{user.avatar.full_path}", {:class => 'avatar'}.merge(options) if user.avatar
  end
  
  def todays_short_date
    Time.now.to_ordinalized_s(:stub)
  end
  
  def yesterdays_short_date
    Time.now.yesterday.to_ordinalized_s(:stub)
  end
  
end
