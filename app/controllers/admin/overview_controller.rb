class Admin::OverviewController < Admin::BaseController
  before_filter :current_site
  
  def index
    @users = User.find(:all)
    @events, @todays_events, @yesterdays_events = [], [], []
    today, yesterday = Time.now.to_date, 1.day.ago.to_date
    Event.find(:all, :order => 'events.created_at DESC', :include => [:article, :user]).each do |event|
      case event.created_at.to_date
        when today     then @todays_events
        when yesterday then @yesterdays_events
        else                @events
      end << event
    end
  end
  
end
