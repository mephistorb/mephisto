class Admin::OverviewController < Admin::BaseController
  before_filter :current_site
  
  def index
    @users = User.find(:all)
    @events, @todays_events, @yesterdays_events = [], [], []
    today, yesterday = Time.now.to_date, 1.day.ago.to_date
    Event.find(:all, :order => 'events.created_at DESC', :include => [:user, :article]).each do |event|
      case event.created_at.to_date
        when today     then @todays_events << event
        when yesterday then @yesterdays_events << event
        else                @events << event
      end
    end
  end
  
end
