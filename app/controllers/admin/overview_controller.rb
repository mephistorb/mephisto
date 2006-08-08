class Admin::OverviewController < Admin::BaseController
  session :off, :only => :feed
  before_filter :basic_auth_required, :only => :feed
  caches_page :feed
  
  helper Admin::ArticlesHelper
  
  def index
    @users = User.find(:all, :order => 'updated_at desc')
    @events, @todays_events, @yesterdays_events = [], [], []
    today, yesterday = Time.now.utc.to_date, 1.day.ago.utc.to_date
    @articles = @site.unapproved_comments.count :all, :group => :article, :order => '1 desc'
    @site.events.find(:all, :order => 'events.created_at DESC', :include => [:article, :user], :limit => 50).each do |event|
      event_date = event.created_at.to_date
      if event_date >= today
        @todays_events
      elsif event_date == yesterday
        @yesterdays_events
      else
        @events
      end << event
    end
  end

  def feed
    @events = @site.events.find(:all, :order => 'events.created_at DESC', :include => [:article, :user], :limit => 25)
    render :layout => false
  end
  
  def delete
    @site.events.find(params[:id]).destroy
    render :update do |page|
      page["event-#{params[:id]}"].visual_effect :drop_out
    end
  end
end
