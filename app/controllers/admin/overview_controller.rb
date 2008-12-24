class Admin::OverviewController < Admin::BaseController
  member_actions << 'index' << 'feed'
  session :off, :only => :feed
  before_filter :basic_auth_required, :only => :feed
  caches_page :feed
  before_filter :protect_action, :only => :delete
  
  helper Admin::ArticlesHelper
  
  def index
    @users = site.users(:order => 'updated_at desc')
    @events, @todays_events, @yesterdays_events = [], [], []
    today, yesterday = utc_to_local(Time.now.utc).to_date, utc_to_local(1.day.ago.utc).to_date
    @articles = @site.unapproved_comments.count :all, :group => :article, :order => '1 desc'
    @site.events.find(:all, :order => 'events.created_at DESC', :include => [:article, :user], :limit => 50).each do |event|
      event_date = utc_to_local(event.created_at).to_date
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
    respond_to do |format|
      format.xml { render :layout => false }
    end
  end
  
  def delete
    @site.events.find(params[:id]).destroy
    render :update do |page|
      page["event-#{params[:id]}"].visual_effect :drop_out
    end
  end
end
